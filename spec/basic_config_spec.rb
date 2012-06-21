require_relative '../lib/basic_config'

describe BasicConfig do
  let(:hash) do
    {
      'one' => 'something',
      'two' => 'other_value',
      'three' => {
        'nested' => '123',
        'more' => {
          'param' => 'value'
        }
      }
    }
  end
  let(:symbolized_hash) do
    {
      one: 'something',
      two: 'other_value',
      three: {
        nested: '123',
        more: {
          param: 'value'
        }
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
    should respond_to :one
    should respond_to :three
    should_not respond_to :unknown
  end
  
  it 'raises BasicConfig::KeyNotFound for unknown keys' do
    expect { subject.four }.to raise_error(BasicConfig::NotFound)
  end

  it 'can be converted back to hash' do
    subject.to_hash.should == symbolized_hash
  end

  describe '.load_file' do
    it 'uses YAML to load files' do
      content = { key: 'value' }
      YAML.stub(:load_file).with('file').and_return(content)
      BasicConfig.load_file('file').to_hash.should == content
    end
  end

  describe '.load_env' do
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
    let(:environment) { 'development' }
    let(:expected_result) { { value: 'x' } }

    it 'selects env section from YAML loaded file' do
      YAML.stub(:load_file).with('file').and_return(content)
      BasicConfig.load_env('file', environment).to_hash.should == expected_result
    end
  end
  
  describe BasicConfig::NotFound do
    let(:exception) do
      begin
        config.missing_key
      rescue BasicConfig::NotFound => expected_failure
        expected_failure
      end
    end
    subject { exception.message }
    let(:original_config) { BasicConfig.new(hash) }
    let(:original_scoping) { '' }
    let(:scoped_missing_key_name) { original_scoping + missing_key_name }

    shared_examples_for 'specific failure' do
      it 'contains the right location' do
        should include location
      end

      it 'contains the right key' do
        should include "'#{scoped_missing_key_name}'"
      end
    end

    shared_examples_for 'construction contexts' do
      context 'when constructed manually' do
        let(:original_config) { BasicConfig.new(hash) }
        let(:location) { 'spec/basic_config_spec.rb:116' }
        
        it_behaves_like 'specific failure'
      end

      context 'when loaded from YAML' do
        let(:content) { hash }
        let(:filename) { 'example.yml' }
        let(:location) { filename }
        
        before do
          YAML.stub(:load_file).with(filename).and_return(content)
        end

        let(:original_config) { BasicConfig.load_file(filename) }

        it_behaves_like 'specific failure'

        context 'with env' do
          let(:content) do
            {
              'development' => hash,
              'test' => hash
            }
          end
          let(:environment) { 'development' }
          let(:original_config) { BasicConfig.load_env(filename, environment) }
          let(:original_scoping) { 'development.' }

          it_behaves_like 'specific failure'
        end
      end
    end

    context 'top-level' do
      let(:config) { original_config }
      let(:missing_key_name) { 'missing_key' }

      it_behaves_like 'construction contexts'
    end

    context 'one-level in' do
      let(:config) { original_config.three }
      let(:missing_key_name) { 'three.missing_key' }

      it_behaves_like 'construction contexts'
    end

    context 'two-levels in' do
      let(:config) { original_config.three.more }
      let(:missing_key_name) { 'three.more.missing_key' }

      it_behaves_like 'construction contexts'
    end
  end
end
