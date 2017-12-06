require 'spec_helper'
require 'kintone/command/records'
require 'kintone/api'
require 'kintone/type'

describe Kintone::Command::Records do
  let(:target) { Kintone::Command::Records.new(api) }
  let(:api) { Kintone::Api.new('example.cybozu.com', 'Administrator', 'cybozu') }

  describe '#get' do
    subject { target.get(app, query, fields) }

    let(:app) { 8 }
    let(:query) { '' }
    let(:fields) { [] }
    let(:request_body) { { app: app, query: query.to_s, totalCount: false, fields: fields } }

    context 'アプリIDだけ指定した時' do
      let(:response_data) do
        { 'records' => [{ 'record_id' => { 'type' => 'RECORD_NUMBER', 'value' => '1' } }] }
      end

      before(:each) do
        stub_request(
          :get,
          'https://example.cybozu.com/k/v1/records.json'
        )
          .with(body: request_body.to_json)
          .to_return(
            body: response_data.to_json,
            status: 200,
            headers: { 'Content-type' => 'application/json' }
          )
      end

      it { expect(subject).to eq response_data }
    end

    context '条件に文字列を含むqueryを指定した時' do
      before(:each) do
        stub_request(
          :get,
          'https://example.cybozu.com/k/v1/records.json'
        )
          .with(body: request_body.to_json)
          .to_return(
            body: response_data.to_json,
            status: 200,
            headers: { 'Content-type' => 'application/json' }
          )
      end

      let(:query) { 'updated_time > "2012-02-03T09:00:00+0900" and updated_time < "2012-02-03T10:00:00+0900"' } # rubocop:disable Metrics/LineLength
      let(:response_data) do
        { 'records' => [{ 'record_id' => { 'type' => 'RECORD_NUMBER', 'value' => '1' } }] }
      end

      it { expect(subject).to eq response_data }
    end

    context '項目に全角文字を含むfieldsを指定した時' do
      before(:each) do
        stub_request(
          :get,
          'https://example.cybozu.com/k/v1/records.json'
        )
          .with(body: request_body.to_json)
          .to_return(
            body: response_data.to_json,
            status: 200,
            headers: { 'Content-type' => 'application/json' }
          )
      end

      let(:fields) { %w[レコード番号 created_time dropdown] }
      let(:response_data) do
        { 'records' => [{ 'record_id' => { 'type' => 'RECORD_NUMBER', 'value' => '1' } }] }
      end

      it { expect(subject).to eq response_data }
    end

    context 'queryにnilを指定した時' do
      before(:each) do
        stub_request(
          :get,
          'https://example.cybozu.com/k/v1/records.json'
        )
          .with(body: request_body.to_json)
          .to_return(
            body: response_data.to_json,
            status: 200,
            headers: { 'Content-type' => 'application/json' }
          )
      end

      let(:query) { nil }
      let(:response_data) do
        { 'records' => [{ 'record_id' => { 'type' => 'RECORD_NUMBER', 'value' => '1' } }] }
      end

      it { expect(subject).to eq response_data }
    end

    context 'fieldsにnilを指定した時' do
      let(:fields) { nil }
      let(:request_body) { { app: app, query: query, totalCount: false } }
      let(:response_data) do
        { 'records' => [{ 'record_id' => { 'type' => 'RECORD_NUMBER', 'value' => '1' } }] }
      end

      before(:each) do
        stub_request(
          :get,
          'https://example.cybozu.com/k/v1/records.json'
        )
          .with(body: request_body.to_json)
          .to_return(
            body: response_data.to_json,
            status: 200,
            headers: { 'Content-type' => 'application/json' }
          )
      end

      it { expect(subject).to eq response_data }
    end

    context 'totalCountにtrueを指定した時' do
      before(:each) do
        stub_request(
          :get,
          'https://example.cybozu.com/k/v1/records.json'
        )
          .with(body: request_body.to_json)
          .to_return(
            body: response_data.to_json,
            status: 200,
            headers: { 'Content-type' => 'application/json' }
          )
      end

      subject { target.get(app, query, fields, total_count: total_count) }

      let(:request_body) { { app: app, query: query, totalCount: total_count, fields: fields } }
      let(:response_data) do
        { 'records' => [{ 'record_id' => { 'type' => 'RECORD_NUMBER', 'value' => '1' } }] }
      end

      let(:total_count) { true }
      it { expect(subject).to eq response_data }
    end

    context 'fail to request' do
      before(:each) do
        stub_request(
          :get,
          'https://example.cybozu.com/k/v1/records.json'
        )
          .with(body: request_body.to_json)
          .to_return(
            body: '{"message":"不正なJSON文字列です。","id":"1505999166-897850006","code":"CB_IJ01"}',
            status: 500,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
      let(:fields) { nil }
      let(:request_body) { { app: app, query: '', totalCount: false } }

      it { expect { subject }.to raise_error Kintone::KintoneError }
    end
  end

  describe '#register' do
    before(:each) do
      stub_request(
        :post,
        'https://example.cybozu.com/k/v1/records.json'
      )
        .with(body: request_body.to_json)
        .to_return(
          body: response_body.to_json,
          status: 200,
          headers: { 'Content-type' => 'application/json' }
        )
    end

    subject { target.register(app, records) }

    let(:app) { 7 }
    let(:request_body) do
      {
        'app' => 7,
        'records' => [
          { 'rich_editor' => { 'value' => 'testtest' } },
          { 'user_select' => { 'value' => [{ 'code' => 'suzuki' }] } }
        ]
      }
    end
    let(:response_body) { { 'ids' => ['100', '101'], 'revisions' => ['1', '1'] } }

    context 'use hash' do
      let(:records) do
        [
          { 'rich_editor' => { 'value' => 'testtest' } },
          { 'user_select' => { 'value' => [{ 'code' => 'suzuki' }] } }
        ]
      end

      it { expect(subject).to eq response_body }
    end

    context 'use record' do
      let(:records) do
        [
          Kintone::Type::Record.new(rich_editor: 'testtest'),
          Kintone::Type::Record.new(user_select: [{ code: 'suzuki' }])
        ]
      end

      it { expect(subject).to eq response_body }
    end

    context 'fail to request' do
      before(:each) do
        stub_request(
          :post,
          'https://example.cybozu.com/k/v1/records.json'
        )
          .with(body: request_body.to_json)
          .to_return(
            body: '{"message":"不正なJSON文字列です。","id":"1505999166-897850006","code":"CB_IJ01"}',
            status: 500,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      let(:records) do
        [
          { 'rich_editor' => { 'value' => 'testtest' } },
          { 'user_select' => { 'value' => [{ 'code' => 'suzuki' }] } }
        ]
      end

      it { expect { subject }.to raise_error Kintone::KintoneError }
    end
  end

  describe '#update' do
    before(:each) do
      stub_request(
        :put,
        'https://example.cybozu.com/k/v1/records.json'
      )
        .with(body: request_body.to_json)
        .to_return(
          body: response_body.to_json,
          status: 200,
          headers: { 'Content-type' => 'application/json' }
        )
    end

    subject { target.update(app, records) }

    let(:app) { 4 }
    let(:response_body) do
      { 'records' => [{ 'id' => '1', 'revision' => '2' }, { 'id' => '2', 'revision' => '2' }] }
    end

    context 'without revision' do
      let(:request_body) do
        {
          'app' => 4,
          'records' => [
            { 'id' => 1, 'record' => { 'string_1' => { 'value' => 'abcdef' } } },
            { 'id' => 2, 'record' => { 'string_multi' => { 'value' => 'opqrstu' } } }
          ]
        }
      end

      context 'use hash' do
        let(:records) do
          [
            { 'id' => 1, 'record' => { 'string_1' => { 'value' => 'abcdef' } } },
            { 'id' => 2, 'record' => { 'string_multi' => { 'value' => 'opqrstu' } } }
          ]
        end

        it { expect(subject).to eq response_body }
      end

      context 'use record' do
        let(:records) do
          [
            { id: 1, record: Kintone::Type::Record.new(string_1: 'abcdef') },
            { id: 2, record: Kintone::Type::Record.new(string_multi: 'opqrstu') }
          ]
        end

        it { expect(subject).to eq response_body }
      end
    end

    context 'with revision' do
      let(:request_body) do
        {
          'app' => 4,
          'records' => [
            {
              'id' => 1,
              'revision' => 1,
              'record' => { 'string_1' => { 'value' => 'abcdef' } }
            },
            {
              'id' => 2,
              'revision' => 1,
              'record' => { 'string_multi' => { 'value' => 'opqrstu' } }
            }
          ]
        }
      end

      context 'use hash' do
        let(:records) do
          [
            {
              'id' => 1,
              'revision' => 1,
              'record' => { 'string_1' => { 'value' => 'abcdef' } }
            },
            {
              'id' => 2,
              'revision' => 1,
              'record' => { 'string_multi' => { 'value' => 'opqrstu' } }
            }
          ]
        end

        it { expect(subject).to eq response_body }
      end

      context 'use record' do
        let(:records) do
          [
            { id: 1, revision: 1, record: Kintone::Type::Record.new(string_1: 'abcdef') },
            { id: 2, revision: 1, record: Kintone::Type::Record.new(string_multi: 'opqrstu') }
          ]
        end

        it { expect(subject).to eq response_body }
      end
    end

    context 'fail to request' do
      before(:each) do
        stub_request(
          :put,
          'https://example.cybozu.com/k/v1/records.json'
        )
          .with(body: request_body.to_json)
          .to_return(
            body: '{"message":"不正なJSON文字列です。","id":"1505999166-897850006","code":"CB_IJ01"}',
            status: 500,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      let(:records) do
        [
          { 'id' => 1, 'record' => { 'string_1' => { 'value' => 'abcdef' } } },
          { 'id' => 2, 'record' => { 'string_multi' => { 'value' => 'opqrstu' } } }
        ]
      end
      let(:request_body) do
        {
          'app' => 4,
          'records' => [
            { 'id' => 1, 'record' => { 'string_1' => { 'value' => 'abcdef' } } },
            { 'id' => 2, 'record' => { 'string_multi' => { 'value' => 'opqrstu' } } }
          ]
        }
      end

      it { expect { subject }.to raise_error Kintone::KintoneError }
    end
  end

  describe '#delete' do
    before(:each) do
      stub_request(
        :delete,
        'https://example.cybozu.com/k/v1/records.json'
      )
        .with(body: request_body.to_json)
        .to_return(
          body: '{}',
          status: 200,
          headers: { 'Content-type' => 'application/json' }
        )
    end

    context 'without revisions' do
      subject { target.delete(app, ids) }

      let(:app) { 1 }
      let(:ids) { [100, 80] }
      let(:request_body) { { app: app, ids: ids } }

      it { expect(subject).to eq({}) }
    end

    context 'with revisions' do
      subject { target.delete(app, ids, revisions: revisions) }

      let(:app) { 1 }
      let(:ids) { [100, 80] }
      let(:revisions) { [1, 4] }
      let(:request_body) { { app: app, ids: ids, revisions: revisions } }

      it { expect(subject).to eq({}) }
    end

    context 'fail to request' do
      before(:each) do
        stub_request(
          :delete,
          'https://example.cybozu.com/k/v1/records.json'
        )
          .with(body: request_body.to_json)
          .to_return(
            body: '{"message":"不正なJSON文字列です。","id":"1505999166-897850006","code":"CB_IJ01"}',
            status: 500,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      subject { target.delete(app, ids) }

      let(:app) { 1 }
      let(:ids) { [100, 80] }
      let(:request_body) { { app: app, ids: ids } }

      it { expect { subject }.to raise_error Kintone::KintoneError }
    end
  end
end
