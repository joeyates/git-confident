require 'rubygems' if RUBY_VERSION < '1.9'
require 'git'

module Git

  class Confident < ::Git::Base

    module VERSION #:nodoc:
      MAJOR = 0
      MINOR = 0
      TINY  = 1
 
      STRING = [ MAJOR, MINOR, TINY ].join( '.' )
    end

    def initialize( path )
      raise "Git repository not found at '#{ path }'" if ! File.directory?( "#{ path }/.git" )
      @path = path.clone
      super( { :working_directory => @path } )
    end

    def files
      ls_files.keys.sort
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
