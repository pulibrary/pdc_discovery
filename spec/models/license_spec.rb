# frozen_string_literal: true

require 'rails_helper'

RSpec.describe License do
  describe 'url' do
    it 'handles minor variations' do
      expect(described_class.url('CC0 License')).to eq 'https://creativecommons.org/publicdomain/zero/1.0/'
      expect(described_class.url('CC0 license')).to eq 'https://creativecommons.org/publicdomain/zero/1.0/'
    end

    it 'handles unknown licenses' do
      expect(described_class.url('blah blah')).to be nil
      expect(described_class.url(nil)).to be nil
    end
  end
end
