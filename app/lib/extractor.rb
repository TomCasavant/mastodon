# frozen_string_literal: true

module Extractor
  MAX_DOMAIN_LENGTH = 253

  extend Twitter::TwitterText::Extractor

  module_function

  def extract_entities_with_indices(text, options = {}, &block)
    entities = extract_urls_with_indices(text, options) +
               extract_hashtags_with_indices(text, check_url_overlap: false) +
               extract_mentions_or_lists_with_indices(text) +
               extract_extra_uris_with_indices(text)

    return [] if entities.empty?

    entities = remove_overlapping_entities(entities)
    entities.each(&block) if block
    entities
  end

  def extract_mentions_or_lists_with_indices(text)
    return [] unless text && Twitter::TwitterText::Regex[:at_signs].match?(text)

    possible_entries = []

    text.scan(Account::MENTION_RE) do |screen_name, _|
      match_data = $LAST_MATCH_INFO
      after      = ::Regexp.last_match.post_match

      unless Twitter::TwitterText::Regex[:end_mention_match].match?(after)
        _, domain = screen_name.split('@')

        next if domain.present? && domain.length > MAX_DOMAIN_LENGTH

        start_position = match_data.char_begin(1) - 1
        end_position   = match_data.char_end(1)

        possible_entries << {
          screen_name: screen_name,
          indices: [start_position, end_position],
        }
      end
    end

    if block_given?
      possible_entries.each do |mention|
        yield mention[:screen_name], mention[:indices].first, mention[:indices].last
      end
    end

    possible_entries
  end

  def extract_hashtags_with_indices(text, _options = {})
    return [] unless text&.index('#')

    possible_entries = []

    text.scan(Tag::HASHTAG_RE) do |hash_text, _|
      match_data     = $LAST_MATCH_INFO
      start_position = match_data.char_begin(1) - 1
      end_position   = match_data.char_end(1)
      after          = ::Regexp.last_match.post_match

      if after.start_with?('://')
        hash_text.match(/(.+)(https?\Z)/) do |matched|
          hash_text     = matched[1]
          end_position -= matched[2].codepoint_length
        end
      end

      possible_entries << {
        hashtag: hash_text,
        indices: [start_position, end_position],
      }
    end

    if block_given?
      possible_entries.each do |tag|
        yield tag[:hashtag], tag[:indices].first, tag[:indices].last
      end
    end

    possible_entries
  end

  def clean_text(text)
    hashtags_with_indices = extract_hashtags_with_indices(text)
    hashtags = hashtags_with_indices.map { |entry| entry[:hashtag] }
    cleaned_text = text.dup

    entities = hashtags_with_indices.map { |entry| { hashtag: true, indices: entry[:indices] } }
    block_begin = nil
    block_end = nil

    entities.each_with_index do |entity, i|
      next unless entity[:hashtag]

      next_entity = entities[i + 1]

      if !next_entity.nil? && !next_entity[:hashtag]
        block_begin = nil
        block_end = nil
        next
      elsif next_entity.nil?
        block_begin = entity[:indices].first if block_begin.nil?
        block_end = entity[:indices].last
        next
      end

      entity_end = entity[:indices].last
      next_entity_start = next_entity[:indices].first

      if next_entity_start == entity_end + 1
        block_begin = entity[:indices].first if block_begin.nil?
        block_end = entity_end
      else
        block_begin = nil
        block_end = nil
      end
    end

    # Remove the block of hashtags at the end of the text
    if block_begin && block_end && cleaned_text[block_end..].strip.empty? && cleaned_text[block_begin - 1] == "\n"
      cleaned_text.slice!(block_begin..block_end)
    end
    [cleaned_text.strip, hashtags]
  end




  def extract_cashtags_with_indices(_text)
    []
  end

  def extract_extra_uris_with_indices(text)
    return [] unless text&.index(':')

    possible_entries = []

    text.scan(Twitter::TwitterText::Regex[:valid_extended_uri]) do
      valid_uri_match_data = $LAST_MATCH_INFO

      start_position = valid_uri_match_data.char_begin(3)
      end_position   = valid_uri_match_data.char_end(3)

      possible_entries << {
        url: valid_uri_match_data[3],
        indices: [start_position, end_position],
      }
    end

    if block_given?
      possible_entries.each do |url|
        yield url[:url], url[:indices].first, url[:indices].last
      end
    end

    possible_entries
  end
end
