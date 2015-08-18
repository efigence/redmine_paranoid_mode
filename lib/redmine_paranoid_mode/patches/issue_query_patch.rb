module RedmineParanoidMode
  module Patches
    module IssueQueryPatch
      def self.included(base)
        base.class_eval do
          unloadable

          self.available_columns <<  QueryColumn.new(:deleted_at, :sortable => "#{Issue.table_name}.deleted_at")

          alias_method :initialize_available_filters_original, :initialize_available_filters

          def initialize_available_filters
            if User.current.admin?
              add_available_filter "deleted_at", :type => :date
            end
            initialize_available_filters_original
          end

        end
      end
    end
  end
end

unless IssueQuery.included_modules.include?(RedmineParanoidMode::Patches::IssueQueryPatch)
  IssueQuery.send(:include, RedmineParanoidMode::Patches::IssueQueryPatch)
end
