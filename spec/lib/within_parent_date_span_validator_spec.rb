require 'spec_helper'

RSpec.describe ActsAsSpan::WithinParentDateSpanValidator do
  let(:new_child) do
    child_class.new(
      start_date: new_child_start_date,
      end_date: new_child_end_date,
      mama: mama)
  end

  let!(:mama) { Mama.create(start_date: mama_start_date, end_date: mama_end_date) }
  let!(:papa) { Papa.create(start_date: papa_start_date, end_date: papa_end_date) }

  let(:mama_start_date) { Date.current - 30.years }
  let(:mama_end_date) { Date.current + 70.years  }

  let(:papa_start_date) { mama_start_date + 1.year }
  let(:papa_end_date) { mama_end_date - 1.year }

  describe 'an object that validates against a single parent' do
    let(:child_class) { OneParentChild }

    context 'valid case' do
      let(:new_child_start_date) { mama_start_date  }
      let(:new_child_end_date) { mama_end_date }

      it 'allows date spans that lie within all respective parental date span' do
        expect(new_child).to be_valid
      end
    end

    context 'invalid cases' do
      let(:new_child_start_date) { mama_start_date - 1 }
      let(:new_child_end_date) { mama_end_date + 1 }

      it 'does not allow date spans that lie outside of respective parental date span' do
        expect(new_child).not_to be_valid
      end
    end
  end

  describe 'an object with multiple parents' do
    let(:child_class) { TwoParentChild }

    before { new_child.papa = papa }

    context 'valid cases' do
      let(:new_child_start_date) { papa_start_date }
      let(:new_child_end_date) { papa_end_date }

      it 'allows date spans that lie within all respective parental date spans' do
        expect(new_child).to be_valid
      end
    end

    context 'invalid cases' do
      let(:new_child_start_date) { papa_start_date - 1 }
      let(:new_child_end_date) { papa_end_date + 1 }

      it 'does not allow date spans that lie outside of respective parental date spans' do
        expect(new_child).not_to be_valid
      end
    end
  end
end
