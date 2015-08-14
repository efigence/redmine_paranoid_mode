module RedmineParanoidMode
  module Patches
    module IssueQueryPatch
      def self.included(base)
        base.class_eval do
          unloadable

          self.queried_class = Issue.with_deleted

          def initialize_available_filters
            principals = []
            subprojects = []
            versions = []
            categories = []
            issue_custom_fields = []

            if project
              principals += project.principals.visible
              unless project.leaf?
                subprojects = project.descendants.visible.to_a
                principals += Principal.member_of(subprojects).visible
              end
              versions = project.shared_versions.to_a
              categories = project.issue_categories.to_a
              issue_custom_fields = project.all_issue_custom_fields
            else
              if all_projects.any?
                principals += Principal.member_of(all_projects).visible
              end
              versions = Version.visible.where(:sharing => 'system').to_a
              issue_custom_fields = IssueCustomField.where(:is_for_all => true)
            end
            principals.uniq!
            principals.sort!
            principals.reject! {|p| p.is_a?(GroupBuiltin)}
            users = principals.select {|p| p.is_a?(User)}

            add_available_filter "status_id",
            :type => :list_status, :values => IssueStatus.sorted.collect{|s| [s.name, s.id.to_s] }

            if project.nil?
              project_values = []
              if User.current.logged? && User.current.memberships.any?
                project_values << ["<< #{l(:label_my_projects).downcase} >>", "mine"]
                project_values << ["<< #{l(:label_opened_projects).downcase} >>", "opened"]
              end
              project_values += all_projects_values
              add_available_filter("project_id",
                :type => :list, :values => project_values
                ) unless project_values.empty?
            end
            add_available_filter "parent_id", :type => :integer, :label => 'field_parent_issue'
            add_available_filter "tracker_id",
            :type => :list, :values => trackers.collect{|s| [s.name, s.id.to_s] }

            add_available_filter "priority_id",
            :type => :list, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] }

            author_values = []
            author_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
            author_values += users.collect{|s| [s.name, s.id.to_s] }
            add_available_filter("author_id",
              :type => :list, :values => author_values
              ) unless author_values.empty?

            assigned_to_values = []
            assigned_to_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
            assigned_to_values += (Setting.issue_group_assignment? ?
              principals : users).collect{|s| [s.name, s.id.to_s] }
            add_available_filter("assigned_to_id",
              :type => :list_optional, :values => assigned_to_values
              ) unless assigned_to_values.empty?

            group_values = Group.givable.visible.collect {|g| [g.name, g.id.to_s] }
            add_available_filter("member_of_group",
              :type => :list_optional, :values => group_values
              ) unless group_values.empty?

            role_values = Role.givable.collect {|r| [r.name, r.id.to_s] }
            add_available_filter("assigned_to_role",
              :type => :list_optional, :values => role_values
              ) unless role_values.empty?

            if versions.any?
              add_available_filter "fixed_version_id",
              :type => :list_optional,
              :values => versions.sort.collect{|s| ["#{s.project.name} - #{s.name}", s.id.to_s] }
            end

            if categories.any?
              add_available_filter "category_id",
              :type => :list_optional,
              :values => categories.collect{|s| [s.name, s.id.to_s] }
            end

            add_available_filter "status_id_was",
            :type => :list, :values => IssueStatus.sorted.collect{|s| [s.name, s.id.to_s] }
            add_available_filter "priority_id_was",
            :type => :list, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] }
            add_available_filter "tracker_id_was",
            :type => :list, :values => trackers.collect{|s| [s.name, s.id.to_s] }
            add_available_filter "assigned_to_id_was",
            :type => :list, :values => assigned_to_values unless assigned_to_values.empty?

            add_available_filter "subject", :type => :text
            add_available_filter "created_on", :type => :date_past
            add_available_filter "updated_on", :type => :date_past
            add_available_filter "closed_on", :type => :date_past
            add_available_filter "start_date", :type => :date
            add_available_filter "due_date", :type => :date
            add_available_filter "estimated_hours", :type => :float
            add_available_filter "done_ratio", :type => :integer

            if User.current.admin?
              add_available_filter "deleted",
              :type => :list,
              :values => [[l(:general_text_yes), "1"], [l(:general_text_no), "0"]]
            end

            if User.current.allowed_to?(:set_issues_private, nil, :global => true) ||
              User.current.allowed_to?(:set_own_issues_private, nil, :global => true)
              add_available_filter "is_private",
              :type => :list,
              :values => [[l(:general_text_yes), "1"], [l(:general_text_no), "0"]]
            end

            if User.current.logged?
              add_available_filter "watcher_id",
              :type => :list, :values => [["<< #{l(:label_me)} >>", "me"]]
            end

            if subprojects.any?
              add_available_filter "subproject_id",
              :type => :list_subprojects,
              :values => subprojects.collect{|s| [s.name, s.id.to_s] }
            end

            add_custom_fields_filters(issue_custom_fields)

            add_associations_custom_fields_filters :project, :author, :assigned_to, :fixed_version

            IssueRelation::TYPES.each do |relation_type, options|
              add_available_filter relation_type, :type => :relation, :label => options[:name]
            end

            Tracker.disabled_core_fields(trackers).each {|field|
              delete_available_filter field
            }
          end

          def available_columns
            return @available_columns if @available_columns
            @available_columns = self.class.available_columns.dup
            @available_columns += (project ?
              project.all_issue_custom_fields :
              IssueCustomField
              ).visible.collect {|cf| QueryCustomFieldColumn.new(cf) }

            if User.current.allowed_to?(:view_time_entries, project, :global => true)
              index = nil
              @available_columns.each_with_index {|column, i| index = i if column.name == :estimated_hours}
              index = (index ? index + 1 : -1)
              # insert the column after estimated_hours or at the end
              @available_columns.insert index, QueryColumn.new(:spent_hours,
                :sortable => "COALESCE((SELECT SUM(hours) FROM #{TimeEntry.table_name} WHERE #{TimeEntry.table_name}.issue_id = #{Issue.table_name}.id), 0)",
                :default_order => 'desc',
                :caption => :label_spent_time
                )
            end

            if User.current.allowed_to?(:set_issues_private, nil, :global => true) ||
              User.current.allowed_to?(:set_own_issues_private, nil, :global => true)
              @available_columns << QueryColumn.new(:is_private, :sortable => "#{Issue.table_name}.is_private")
            end

            if User.current.admin?
              @available_columns <<QueryColumn.new(:deleted, :sortable => "#{Issue.table_name}.deleted_at")
            end

            disabled_fields = Tracker.disabled_core_fields(trackers).map {|field| field.sub(/_id$/, '')}
            @available_columns.reject! {|column|
              disabled_fields.include?(column.name.to_s)
            }

            @available_columns
          end

          def sql_for_deleted_field(field, operator, value)
            # if no => deleted_at = nil
            # else
            #   deleted_at not

            op = (operator == "=" ? '=' : '!=')
            va = (value == '0' ? self.class.connection.quoted_false : self.class.connection.quoted_true)

            "#{Issue.table_name}.deleted_at #{op} #{va}"
          end

        end
      end
    end
  end
end

unless IssueQuery.included_modules.include?(RedmineParanoidMode::Patches::IssueQueryPatch)
  IssueQuery.send(:include, RedmineParanoidMode::Patches::IssueQueryPatch)
end
