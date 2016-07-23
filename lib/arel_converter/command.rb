require 'optparse'

module ArelConverter

  class Command

    attr_accessor :options

    def initialize(*args)
      args << '--help' if args.empty?
      @translators = ['scope','finder','association']
      @options = {}
      parse_argv(*args)
    end

    def run!
      if @translators.include?('association')
        puts "== Checking Associations"
        ArelConverter::Association.new(options[:path], options).run!
      end

      if @translators.include?('scope')
        puts "\n== Checking Scopes"
        ArelConverter::Scope.new(options[:path], options).run!
        ArelConverter::DefaultScope.new(options[:path], options).run!
      end

      if @translators.include?('finder')
        puts "\n== Checking Finders"
        ArelConverter::ActiveRecordFinder.new(options[:path], options).run!
      end
    end

  private

    def parse_argv(*args)
      OptionParser.new do |opts|
        opts.banner = "Usage: arel_convert [options] [PATH]"
        opts.on('-t', '--translators [scope,finder,association]', Array, 'Specify specific translators') { |list| @translators = list }
        opts.on('--dry-run', 'Run a simulated update, files will not be updated' ) { |v| options[:dry_run] = true }
        opts.on('-h', '--help', 'Display this screen' ) do
          puts opts
          exit 0
        end
      end.parse!(args)
      options[:path] = args.empty? ? '.' : args.shift
    end

  end

end
