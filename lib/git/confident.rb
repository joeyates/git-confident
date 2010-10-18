require 'rubygems' if RUBY_VERSION < '1.9'
require 'git'
require 'git/elements'

module Git

  class Confident < ::Git::Base

    module VERSION #:nodoc:
      MAJOR = 0
      MINOR = 0
      TINY  = 7
 
      STRING = [ MAJOR, MINOR, TINY ].join( '.' )
    end

    attr_reader :elements

    def initialize( options )
      @path      = options[ :path ].clone
      @no_commit = options[ :no_commit ] ? true : false

      raise "Git repository not found at '#{ @path }'" if ! File.directory?( "#{ @path }/.git" )

      super( { :working_directory => @path } )
      @elements = Git::Elements.new( @path )

      case options[ :action ]
      when :backup
        backup
      when :list
        puts "Files:"
        puts @elements.files
        puts "Folders:"
        puts @elements.folders
        puts "Ignored:"
        puts @elements.ignored
      when :restore
        restore
      end     
    end

    private

    def backup
      local_backup
      return if @no_commit
      commit
      push
    end

    def restore
      IO.popen( "rsync --no-perms --executability --keep-dirlinks --delete --files-from=- #{ @path }/ /", "w+" ) do | pipe |
        (@elements.files + @elements.folders).each { | pathname | pipe.puts pathname }
      end
    end

    def local_backup
      IO.popen( "rsync -a --recursive --delete --files-from=- / #{ @path }/", "w+" ) do | pipe |
        (@elements.files + @elements.folders).each { | pathname | pipe.puts pathname }
      end
    end

    def commit
      needs_commit = (status.changed.size + status.untracked.size) > 0
      return if ! needs_commit
      add
      super( "Automatic commit at #{ Time.now }", {:add_all => true} )
    end

    def push
      super( 'origin', lib.branch_current )
    end

  end

end
