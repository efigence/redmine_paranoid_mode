module RedmineParanoidMode
  module Patches
    module ApplicationController
      def self.included(base)
        base.class_eval do
          unloadable

          # Find the issue whose id is the :id parameter
          # Raises a Unauthorized exception if the issue is not visible
          def find_issue
            # Issue.visible.find(...) can not be used to redirect user to the login form
            # if the issue actually exists but requires authentication
            if User.current.admin?
              @issue = Issue.with_deleted.find(params[:id])
            else
              @issue = Issue.find(params[:id])
            end
            raise Unauthorized unless @issue.visible?
            @project = @issue.project
          rescue ActiveRecord::RecordNotFound
            render_404
          end

          # Find issues with a single :id param or :ids array param
          # Raises a Unauthorized exception if one of the issues is not visible
          def find_issues
            if User.current.admin?
              @issues = Issue.with_deleted.where(:id => (params[:id] || params[:ids])).preload(:project, :status, :tracker, :priority, :author, :assigned_to, :relations_to).to_a
            else
              @issues = Issue.where(:id => (params[:id] || params[:ids])).preload(:project, :status, :tracker, :priority, :author, :assigned_to, :relations_to).to_a
            end
            raise ActiveRecord::RecordNotFound if @issues.empty?
            raise Unauthorized unless @issues.all?(&:visible?)
            @projects = @issues.collect(&:project).compact.uniq
            @project = @projects.first if @projects.size == 1
          rescue ActiveRecord::RecordNotFound
            render_404
          end

        end
      end
    end
  end
end

unless ApplicationController.included_modules.include?(RedmineParanoidMode::Patches::ApplicationController)
  ApplicationController.send(:include, RedmineParanoidMode::Patches::ApplicationController)
end
