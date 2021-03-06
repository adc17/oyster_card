require 'oyster_card'

describe OysterCard do
  subject { OysterCard.new }
  alias_method :oyster_card, :subject
  let(:fare) { OysterCard::FARE }
  let(:balance_limit ) { OysterCard::BALANCE_LIMIT }

  it 'has a BALANCE_LIMIT' do
    expect(balance_limit).to be_an_instance_of(Integer)
  end

  it 'has a FARE' do
    expect(fare).to be_an_instance_of(Integer)
  end

  describe '#balance' do
    it 'is set to 0 at initialization' do
      expect(oyster_card.balance).to eq 0
    end
  end

  describe '#top_up' do
    it 'increases the balance by the specified amount' do
      expect { oyster_card.top_up(5) }.to change { oyster_card.balance }.by 5
    end

    it 'raises error if top-up would take balance over BALANCE_LIMIT' do
      oyster_card.top_up(balance_limit)
      expect { oyster_card.top_up(1) }.to raise_error "Error: Balance cannot exceed $#{balance_limit}"
    end
  end

  context 'card is topped up' do
    before { oyster_card.top_up(balance_limit) }

    describe '#touch_in' do
      it 'raises error if card in journey' do
        oyster_card.touch_in
        expect { oyster_card.touch_in }.to raise_error "Error: Card already in journey"
      end
    end

    describe '#touch_out' do
      it 'raises error if card not in journey' do
        expect { oyster_card.touch_out }.to raise_error "Error: Card not in journey"
      end

      it 'deducts fare from card' do
        oyster_card.touch_in
        expect{ oyster_card.touch_out }.to change{ oyster_card.balance }.by (-fare)
      end
    end

    describe '#in_journey?' do
      it 'is not truthy when card has just been initialized' do
        expect(oyster_card).to_not be_in_journey
      end

      it 'is truthy when card has been touched in' do
        oyster_card.touch_in
        expect(oyster_card).to be_in_journey
      end

      it 'is falsey when card has been touched out' do
        oyster_card.touch_in
        oyster_card.touch_out
        expect(oyster_card).to_not be_in_journey
      end
    end

  end

  context 'card is not sufficiently topped up' do

    describe '#touch_in' do
      it 'raises error if balance is less than FARE' do
        oyster_card.top_up(fare - 1)
        expect{ oyster_card.touch_in }.to raise_error "Error: Insufficient funds"
      end
    end
  end

end
