require 'rubygems' if RUBY_VERSION < '1.9'
require 'spec'
require 'git'

SPEC_PATH = File.expand_path( File.dirname( __FILE__ ) )
ROOT_PATH = File.dirname( SPEC_PATH )
require File.join( ROOT_PATH, 'lib', 'git', 'confident' )

describe 'when handling the repository' do

  before( :each ) do
    @repo_path = File.join( SPEC_PATH, 'repo' )
    repo = Git::Base.init( @repo_path )
    File.open( File.join( @repo_path, 'test_file' ), 'w' ) do | file |
      file.write "Hello"
    end
    repo.add 'test_file'
  end

  after( :each ) do
    `rm -rf '#{ @repo_path }'`
  end

  it 'lists files' do
    conf = Git::Confident.new( @repo_path )
    conf.files.should == [ 'test_file' ]
  end

end
