require 'rubygems' if RUBY_VERSION < '1.9'
require 'git'
require 'git/elements'

module Git

  class Confident < ::Git::Base

    module VERSION #:nodoc:
      MAJOR = 0
      MINOR = 0
      TINY  = 8

      STRING = [ MAJOR, MINOR, TINY ].join( '.' )
    end

    attr_reader :elements

    def initialize( options )
      @path      = options[ :path ].clone
      @files     = options[ :files ]
      @no_commit = options[ :no_commit ] ? true : false

      raise "Git repository not found at '#{ @path }'" if ! File.directory?( "#{ @path }/.git" )

      super( { :working_directory => @path } )
      @elements = Git::Elements.new( @path )

      case options[ :action ]
      when :backup
        backup
      when :diff
        diff
      when :list
        list
      when :restore
        restore
      end
    end

    private

    def file_list
      if @files
        @files
      else
        @elements.files + @elements.folders
      end
    end

    def backup
      local_backup
      return if @no_commit
      commit
      push
    end

    def diff
      file_list.each do | pathname |
        s = `diff -U 2 #{ @path }/#{ pathname } /#{ pathname }`
        puts s unless s.empty?
      end
    end

    def list
      @elements = Git::Elements.new( @path )
      puts "Files:"
      puts @elements.files
      puts "Folders:"
      puts @elements.folders
      puts "Ignored:"
      puts @elements.ignored
    end

    def restore
      IO.popen( "rsync --no-perms --executability --keep-dirlinks --delete --files-from=- #{ @path }/ /", "w+" ) do | pipe |
        file_list.each { | pathname | pipe.puts pathname }
      end
    end

    def local_backup
      IO.popen( "rsync -a --recursive --copy-dirlinks --delete --files-from=- / #{ @path }/", "w+" ) do | pipe |
        file_list.each { | pathname | pipe.puts pathname }
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
