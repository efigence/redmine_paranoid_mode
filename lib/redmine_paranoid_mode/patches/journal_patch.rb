module RedmineParanoidMode
  module Patches
    module JournalPatch
      def self.included(base)
        base.class_eval do
          unloadable

          acts_as_paranoid

          safe_attributes 'deleted_at'

        end
      end
    end
  end
end

unless Journal.included_modules.include?(RedmineParanoidMode::Patches::JournalPatch)
  Journal.send(:include, RedmineParanoidMode::Patches::JournalPatch)
end
