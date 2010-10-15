require 'rubygems' if RUBY_VERSION < '1.9'
require 'git'

module Git

  class Elements < Git::Base
    IGNORE    = 'gcignore'
    RECURSIVE = 'gcrecursive'

    def initialize( path )
      @path = path.clone
      super( { :working_directory => @path } )
    end

    def files
      ls_files.keys.reject do | f |
        name = File.basename( f )
        name =~ /^\.#{IGNORE}$/i or name =~ /^\.#{RECURSIVE}$/i
      end
    end

    def ignored
      ignores = ls_files.keys.select do | f |
        File.basename( f ) =~ /^\.#{IGNORE}$/i
      end
      gcfiles_scan ignores
    end

    def folders
      recursives = ls_files.keys.select do | f |
        File.basename( f ) =~ /^\.#{RECURSIVE}$/i
      end
      gcfiles_scan( recursives ).collect { |f| f + '/' }
    end

    def all
      selected_files = files.reject do | f |
        (ignored + folders).find { |i| f =~ /^#{i}/ }
      end
      selected_files + folders
    end

    private

    def gcfiles_scan( files )
      files.collect do | file |
        full_path = File.expand_path( file, @path )
        relative_path = File.dirname( file )

        next [relative_path] if File.zero?( full_path )

        File.open( full_path ).collect do | line |
          line.chomp!
          next if line.empty?
          next line if relative_path == '.'
          File.join( relative_path, line )
        end.compact
      end.flatten
    end

  end

end
