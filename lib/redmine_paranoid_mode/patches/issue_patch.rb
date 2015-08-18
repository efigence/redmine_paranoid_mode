module RedmineParanoidMode
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          unloadable

          acts_as_paranoid

          has_many :journals,  -> { with_deleted }, :as => :journalized, :dependent => :destroy, :inverse_of => :journalized

          safe_attributes 'deleted_at'

          scope :visible, lambda {|*args|
            joins(:project).
            where(Issue.visible_condition(args.shift || User.current, *args))
            if User.current.admin?
              unscope(where: :deleted_at)
            end
          }

        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineParanoidMode::Patches::IssuePatch)
  Issue.send(:include, RedmineParanoidMode::Patches::IssuePatch)
end

