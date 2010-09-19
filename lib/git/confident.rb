require 'rubygems' if RUBY_VERSION < '1.9'
require 'git'

module Git

  class Confident < ::Git::Base

    module VERSION #:nodoc:
      MAJOR = 0
      MINOR = 0
      TINY  = 4
 
      STRING = [ MAJOR, MINOR, TINY ].join( '.' )
    end

    def initialize( options )
      @path      = options[ :path ].clone
      @no_commit = options[ :no_commit ] ? true : false

      raise "Git repository not found at '#{ @path }'" if ! File.directory?( "#{ @path }/.git" )

      super( { :working_directory => @path } )

      case options[ :action ]
      when :backup
        backup
      when :list
        puts files
      when :restore
        restore
      end     
    end

    def files
      ls_files.keys.sort
    end

    private

    def backup
      local_backup
      return if @no_commit
      commit
      push
    end

    def restore
      IO.popen( "rsync --no-perms --executability --files-from=- #{ @path }/ /", "w+" ) do | pipe |
        files.each { | pathname | pipe.puts pathname }
      end
    end

    def local_backup
      IO.popen( "rsync -av --files-from=- / #{ @path }/", "w+" ) do | pipe |
        files.each { | pathname | pipe.puts pathname }
      end
    end

    def commit
      needs_commit = status.changed.size > 0
      return if ! needs_commit
      add
      super( "Automatic commit at #{ Time.now }" )
    end

    def push
      super( 'origin', lib.branch_current )
    end

  end

end
