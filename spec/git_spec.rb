require 'rubygems' if RUBY_VERSION < '1.9'
require 'spec'
require 'git'

SPEC_PATH = File.expand_path( File.dirname( __FILE__ ) )
ROOT_PATH = File.dirname( SPEC_PATH )
require File.join( ROOT_PATH, 'lib', 'git', 'confident' )

Joiner = lambda do |base|
  lambda do |*others|
    File.join(base, *others)
  end
end

describe 'when handling the repository' do

  before( :all ) do
    @backup_path = Joiner[ SPEC_PATH ][ 'gcbkp' ]
    @source_path = Joiner[ 'tmp' ][ 'gcsrc' ]
    @backup_join = Joiner[ @backup_path ]
    @source_join = Joiner[ @source_path ]
    repo = Git::Base.init( @backup_path )

    test_files = [ 'file',
                    'folder/file2',
                    'folder/file3',
                    'folder/folder2/file4',
                    'folder/folder2/file5',
                    'folder/folder3/file6',
                    'folder/folder3/file7',
                    'ignore_me' ]
    FileUtils.mkdir_p( @backup_join[ @source_path, 'folder/folder2' ] )
    FileUtils.mkdir_p( @backup_join[ @source_path, 'folder/folder3' ] )
    test_files.each { |tf| File.open( @backup_join[ @source_path, tf ], 'w' ) }
    File.open( @backup_join[ @source_path, 'folder/folder3/.gcignore' ], 'w' ) { |file| file.write 'file7' }
    File.open( @backup_join[ '.gcignore' ], 'w' ) { |file| file.write <<ASD
#{@source_join[ 'ignore_me' ]}
#{@source_join[ 'wrong_file' ]}
ASD
    }
    File.open( @backup_join[ '.gcrecursive' ], 'w' ) { |file| file.write @source_join[ 'folder/folder2' ] }
    repo.add '*'
  end

  after( :all ) do
    `rm -rf '#{ @backup_path }'`
    `rm -rf '/#{ @source_path }'`
  end

  it 'lists files' do
    conf = Git::Confident.new( :path => @backup_path )
    expected = [ 'file',
                 'folder/file2',
                 'folder/file3',
                 'folder/folder3/file6' ]
    conf.elements.files.should == expected.collect { |e| @source_join[ e ] }
  end

  it 'lists ignored files' do
    conf = Git::Confident.new( :path => @backup_path )
    expected = [ 'folder/folder3/file7',
                 'ignore_me',
                 'wrong_file' ]
    conf.elements.ignored.should == expected.collect { |e| @source_join[ e ] }
  end

  it 'lists recursive folders' do
    conf = Git::Confident.new( :path => @backup_path )
    conf.elements.folders.should == [ @source_join[ 'folder/folder2/' ] ]
  end

  it 'restores backup' do
    conf = Git::Confident.new( :path => @backup_path, :action => :restore )
    source_abs_join = Joiner[ '/' + @source_path ]
    restored = Dir.glob( source_abs_join[ '**/*' ] )
    expected = [ 'file',
                 'folder',
                 'folder/file2',
                 'folder/file3',
                 'folder/folder2',
                 'folder/folder2/file4',
                 'folder/folder2/file5',
                 'folder/folder3',
                 'folder/folder3/file6' ]
    restored.sort.should == expected.collect { |e| source_abs_join[ e ] }.sort
  end

end
