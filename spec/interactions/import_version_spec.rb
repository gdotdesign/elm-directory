describe ImportVersion do
  subject { described_class.run! params }

  let(:params) { { package: 'gdotdesign/elm-ui', version: '0.4.0' } }

  it 'should validate repository' do
    subject
  end
end
