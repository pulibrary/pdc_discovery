# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NameSynonym do
  let(:wiki_response_body) { file_fixture("wiki_english_names.json").read }
  let(:file_name) { Rails.root.join('tmp', 'nametest') }
  let(:wiki_uri) { URI('https://en.wiktionary.org/w/api.php?action=parse&page=Appendix:English_given_names&prop=wikitext&format=json') }
  describe 'build_solr_synonym_file' do
    it 'builds the synonum file' do
      allow(Net::HTTP).to receive(:get).with(wiki_uri)
                                       .and_return(wiki_response_body)
      described_class.build_solr_synonym_file(file_name)
      expect(Net::HTTP).to have_received(:get)
      expect(File.open(file_name).read)
        .to eq(
          "# NOTE!!!\n# This file was automatically generates by running: bundle exec rake names:synonyms \n# !!!!"\
          "\naaron,ron,ronny\nbailee,lee\ncalvin,cal\ndamian,ian\nedmund,ed,eddy,ned,neddy,ted,teddy\nfabian,fabes,ian\ngabriel,gabe,gaby\nhannah,anna,ann,annie,\ningrid,ing\n" \
          "jack,jacky\nkatherine,kathy,kat,katie,kate,kit,kitty,katy,karen,erin\nlachlan,lachy\nmadelina,madeline\nnatasha,tasha,tash,nat\noliver,ollie,ol,olly,oliwa,oli\n"\
          "pamela,pam\nquincy,quin,quinn,quince\nquinton,quavie,quavix,quin,quinn\nrachel,ray or rach\nsalvador,sal\ntamara,tammy,tam\nuna,oona\nvalentine,val\n"\
          "wallace,walt,wally,wal\nxander,xan,xandy,xolo\nyin,xin,chinn,yip,china\nzacarias,zachary\n"
        )
    end
  end
end
