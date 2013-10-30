require "arel_converter/version"
require 'ruby2ruby'
require 'ruby_parser'
require 'logging'

$:.unshift(File.dirname(__FILE__))

require File.join('arel_converter', 'base')
require File.join('arel_converter', 'formatter')
require File.join('arel_converter', 'active_record_finder')
require File.join('arel_converter', 'scope')

module ArelConverter
  class Converter < Ruby2Ruby

    def self.translate(klass_or_str, method = nil)
      puts "OPENING EXPRESSION: #{klass_or_str}"
      parser    = RubyParser.new
      sexp      = parser.process(klass_or_str)
      self.new.process(sexp)
    end

    def logger
      @logger ||= setup_logger(:debug)
    end

    def process_call(exp)
      logger.debug("CALL: #{exp}")
      super
    end

    def process_lit(exp)
      logger.debug("LITERAL: #{exp}")
      super
    end

    def process_hash(exp) # :nodoc:
      result = []

      until exp.empty?
        lhs = process(exp.shift)
        rhs = exp.shift
        t = rhs.first
        logger.debug("HASH-BEFORE => LHS: #{lhs}; t: #{t}; RHS: #{rhs}")
        rhs =  lhs == ':conditions' && t == :hash ? process_conditions_hash(rhs) : process(rhs)
        rhs = "(#{rhs})" unless [:lit, :str, :hash, :array].include? t
        result << hash_to_arel(lhs,rhs) # "#{lhs} => #{rhs}"
      end

      return result.empty? ? "{}" : "{ #{result.join(', ')} }"
    end

    def process_conditions_hash(exp) # :nodoc:
      result = []
      exp.shift
      until exp.empty?
        lhs = process(exp.shift)
        rhs = exp.shift
        t = rhs.first
        rhs = process rhs
        rhs = "(#{rhs})" unless [:lit, :str].include? t 

        result << "#{lhs.sub(':','')}: #{rhs}"
      end

      return result.empty? ? "" : " #{result.join(', ')} "
    end

    #def process_hash(exp)
      #result = []

      #if @conditions_hash
        #result.push process_conditions_hash(exp)
        #@conditions_hash = false
      #else

        #until exp.empty?
          #logger.debug("HASH-EXPRESSION: #{exp}")
          #lhs = process(exp.shift)
          #rhs = exp.shift
          #t = rhs.first

          #@conditions_hash = (lhs == ':conditions' && t == :hash)

          #logger.debug("HASH-BEFORE => LHS: #{lhs}; RHS: #{rhs}")
          #rhs = process rhs
          #logger.debug("HASH-AFTER => LHS: #{lhs}; RHS: #{rhs}")

          #rhs = "#{rhs}" unless [:lit, :str].include? t # TODO: verify better!

          #result.push( hash_to_arel(lhs,rhs) )
        #end
      #end
      #logger.debug("HASH-RESULTS: #{result.join('.')}")
      #return result.join('.')
    #end

    def hash_to_arel(lhs, rhs)
      case lhs
      when ':conditions'
        key = 'where'
      when ':include'
        key = 'includes'
      else
        key = lhs.sub(':','')
      end
      logger.debug("KEY: #{key}(#{rhs})")

      "#{key}(#{rhs})"
    end


    #def process_conditions_hash(exp)
      #logger.debug("CONDITION-HASH-EXP: #{exp}")
      #result = []
      #until exp.empty?
        #lhs = process(exp.shift)
        #rhs = exp.shift
        #t = rhs.first
        #rhs = process rhs
        ## rhs = "(#{rhs})" unless [:lit, :str, :true, :false].include? t # TODO: verify better!

        #result << "#{lhs.sub(':','')}: #{rhs}"
      #end

      #case self.context[1]
      #when :arglist, :argscat then
        #unless result.empty? then
          ## HACK - this will break w/ 2 hashes as args
          #if BINARY.include? @calls.last then
            #return "{#{result.join(', ')}}"
          #else
            #return "#{result.join(', ')}"
          #end
        #else
          #return "{}"
        #end
      #else
        #return "{#{result.join(', ')}}"
      #end
    #end

    private

    def setup_logger(log_level = :info)
      logging = Logging::Logger[self]
      layout = Logging::Layouts::Pattern.new(:pattern => "[%d, %c, %5l] %m\n")

      stdout = Logging::Appenders.stdout
      stdout.level = log_level

      #file = Logging::Appenders::File.new("./log/converters.log")
      #file.layout = layout
      #file.level = :debug

      logging.add_appenders(stdout)
      logging
    end
  end

end