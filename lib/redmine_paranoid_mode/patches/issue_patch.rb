module RedmineParanoidMode
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          unloadable

          acts_as_paranoid if self.attribute_method?(:deleted_at)

          safe_attributes 'deleted_at'

          scope :visible, lambda {|*args|
            if User.current.admin?
              unscope(where: :deleted_at)
            end
            joins(:project).
            where(Issue.visible_condition(args.shift || User.current, *args))
          }

        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineParanoidMode::Patches::IssuePatch)
  Issue.send(:include, RedmineParanoidMode::Patches::IssuePatch)
end

