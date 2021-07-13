# frozen_string_literal: true

RSpec.describe Cli do
  let(:astrophysical_sciences_handle) { "88435/dsp015m60qr913" }
  let(:options) do
    {
      collection_handle: astrophysical_sciences_handle
    }
  end

  context 'index a single handle' do
    let(:cli) { described_class.new }

    it 'take a handle as an argument' do
      expect { cli.invoke(:index, [], options) }.to output(/#{astrophysical_sciences_handle}/).to_stdout
    end
  end
end
