# frozen_string_literal: true
require 'minitest'
require 'capybara/dsl'

module Capybara
  module Minitest

    def assert_text(*args)
      self.assertions += 1
      subject, *args = determine_subject(args)
      subject.assert_text(*args)
    rescue Capybara::ExpectationNotMet => e
      raise Minitest::Assertion, e.message
    end
    alias_method :assert_content, :assert_text

    def assert_no_text(*args)
      self.assertions += 1
      subject, *args = determine_subject(args)
      subject.assert_no_text(*args)
    rescue Capybara::ExpectationNotMet => e
      raise Minitest::Assertion, e.message
    end
    alias_method :refute_text, :assert_no_text
    alias_method :refute_content, :refute_text
    alias_method :assert_no_content, :refute_text

    def assert_selector(*args)
      self.assertions +=1
      subject, *args = determine_subject(args)
      subject.assert_selector(*args)
    rescue Capybara::ExpectationNotMet => e
      raise Minitest::Assertion, e.message
    end

    def assert_no_selector(*args)
      self.assertions +=1
      subject, *args = determine_subject(args)
      subject.assert_no_selector(*args)
    rescue Capybara::ExpectationNotMet => e
      raise Minitest::Assertion, e.message
    end
    alias_method :refute_selector, :assert_no_selector

    def assert_matches_selector(*args)
      self.assertions += 1
      subject, *args = determine_subject(args)
      subject.assert_matches_selector(*args)
    rescue Capybara::ExpectationNotMet => e
      raise Minitest::Assertion, e.message
    end

    def assert_not_matches_selector(*args)
      self.assertions += 1
      subject, *args = determine_subject(args)
      subject.assert_not_matches_selector(*args)
    rescue Capybara::ExpectationNotMet => e
      raise Minitest::Assertion, e.message
    end
    alias_method :refute_matches_selector, :assert_not_matches_selector

    %w(title current_path).each do |selector_type|
      define_method "assert_#{selector_type}" do |*args|
        begin
          self.assertions += 1
          subject, *args = determine_subject(args)
          subject.public_send("assert_#{selector_type}",*args)
        rescue Capybara::ExpectationNotMet => e
          raise Minitest::Assertion, e.message
        end
      end

      define_method "assert_no_#{selector_type}" do |*args|
        begin
          self.assertions += 1
          subject, *args = determine_subject(args)
          subject.public_send("assert_no_#{selector_type}",*args)
        rescue Capybara::ExpectationNotMet => e
          raise Minitest::Assertion, e.message
        end
      end
      alias_method "refute_#{selector_type}", "assert_no_#{selector_type}"
    end

    %w(xpath css link button field select table).each do |selector_type|
      define_method "assert_#{selector_type}" do |*args, &optional_filter_block|
        subject, *args = determine_subject(args)
        locator, options = *args, {}
        locator, options = nil, locator if locator.is_a? Hash
        assert_selector(subject, selector_type.to_sym, locator, options, &optional_filter_block)
      end

      define_method "assert_no_#{selector_type}" do |*args, &optional_filter_block|
        subject, *args = determine_subject(args)
        locator, options = *args, {}
        locator, options = nil, locator if locator.is_a? Hash
        assert_no_selector(subject, selector_type.to_sym, locator, options, &optional_filter_block)
      end
      alias_method "refute_#{selector_type}", "assert_no_#{selector_type}"
    end

    def assert_matches_xpath(*args, &optional_filter_block)
      subject, *args = determine_subject(args)
      assert_matches_selector(subject, :xpath, *args, &optional_filter_block)
    end

    def assert_matches_css(*args, &optional_filter_block)
      subject, *args = determine_subject(args)
      assert_matches_selector(subject, :css, *args, &optional_filter_block)
    end

    def assert_checked_field(*args, &optional_filter_block)
      subject, *args = determine_subject(args)
      locator, options = *args, {}
      locator, options = nil, locator if locator.is_a? Hash
      assert_selector(subject, :field, locator, options.merge(checked: true), &optional_filter_block)
    end

    def assert_unchecked_field(*args, &optional_filter_block)
      subject, *args = determine_subject(args)
      locator, options = *args, {}
      locator, options = nil, locator if locator.is_a? Hash
      assert_selector(subject, :field, locator, options.merge(unchecked: true), &optional_filter_block)
    end

    private

    def determine_subject(args)
      case args.first
      when Capybara::Session, Capybara::Node::Base, Capybara::Node::Simple
        args
      else
        [page, *args]
      end
    end
  end
end
