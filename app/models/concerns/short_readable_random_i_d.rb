module ShortReadableRandomID
  extend ActiveSupport::Concern

  included do
    # Define pool for ID's - excludes easily confusable characters - 0/O and I/1
    # standard:disable Lint/ConstantDefinitionInBlock
    ALPHABET = %w[A B C D E F G H J K L M N P Q R S T U V W X Y Z 2 3 4 5 6 7 8 9].freeze
    # standard:enable Lint/ConstantDefinitionInBlock

    def generate_unique_hrid(srr_id_attr, conditions = {})
      10.times do
        result = SecureRandom.alphanumeric(6, chars: ALPHABET)
        return result unless self.class.find_by(conditions.merge(srr_id_attr => result))
      end
      raise "Could not generate a unique id for #{self.class.name}.#{srr_id_attr} with #{conditions}"
    end
  end
end
