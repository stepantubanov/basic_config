require_relative '../lib/basic_config'

describe BasicConfig do
  let(:hash) do
    {
      'one' => 'something',
      'two' => 'other_value',
      'three' => {
        'nested' => '123'
      }
    }
  end
  let(:symbolized_hash) do
    {
      :one => 'something',
      :two => 'other_value',
      :three => {
        :nested => '123'
      }
    }
  end

  subject { BasicConfig.new(hash) }

  it 'can not be created with nil' do
    expect { BasicConfig.new(nil) }.to raise_error(ArgumentError)
  end

  it 'provides with getters for keys' do
    subject.one.should == 'something'
    subject.two.should == 'other_value'
  end

  it 'symbolizes keys' do
    subject.to_hash.keys.first.should be_a Symbol
  end

  it 'transforms nested hashes into BasicConfigs' do
    subject.three.should be_a BasicConfig
    subject.three.nested.should == '123'
  end

  it 'correctly handles respond_to? queries' do
    subject.should respond_to :one
    subject.should respond_to :three
    subject.should_not respond_to :unknown
  end

  it 'raises NoMethodError for unknown keys' do
    expect { subject.four }.to raise_error(NoMethodError)
  end

  it 'can be converted back to hash' do
    subject.to_hash.should == symbolized_hash
  end

  describe '::load_file' do
    it 'uses YAML to load files' do
      YAML.should_receive(:load_file).with('file').and_return(:content)
      BasicConfig.should_receive(:new).with(:content)
      BasicConfig.load_file('file')
    end
  end

  describe '::load_env' do
    let(:content) do
      {
        'development' => {
          'value' => 'x'
        },
        'test' => {
          'value' => 'y'
        }
      }
    end
    it 'selects env section from YAML loaded file' do
      YAML.should_receive(:load_file).with('file').and_return(content)
      BasicConfig.should_receive(:new).with(content['development'])
      BasicConfig.load_env('file', 'development')
    end
  end
end
