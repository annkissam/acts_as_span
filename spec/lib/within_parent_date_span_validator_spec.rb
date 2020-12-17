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

  let(:thirty_years_ago) { Date.current - 30.years }
  let(:seventy_years_in_the_future) { Date.current + 70.years }

  let(:mama_start_date) { thirty_years_ago }
  let(:mama_end_date) { seventy_years_in_the_future }

  let(:papa_start_date) { thirty_years_ago + 1.year }
  let(:papa_end_date) { seventy_years_in_the_future - 1.year }

  describe 'an object that validates against a single parent' do
    let(:child_class) { OneParentChild }

    context 'inside parent date span' do
      let(:new_child_start_date) { mama_start_date }
      let(:new_child_end_date) { mama_end_date }

      it do
        expect(new_child).to be_valid
      end
    end

    context 'child_record_without_start_date' do
      let(:new_child_start_date) { nil }
      let(:new_child_end_date) { mama_end_date }

      it do
        expect(new_child).to be_invalid
      end
    end

    context 'child_record_without_start_date' do
      let(:new_child_start_date) { mama_start_date }
      let(:new_child_end_date) { nil }

      it do
        expect(new_child).to be_invalid
      end
    end

    context 'child_record_started_before_parent_record' do
      let(:new_child_start_date) { mama_start_date - 1 }
      let(:new_child_end_date) { mama_end_date }

      it do
        expect(new_child).to be_invalid
      end
    end

    context 'child_record_ended_after_parent_record' do
      let(:new_child_start_date) { mama_start_date }
      let(:new_child_end_date) { mama_end_date + 1 }

      it do
        expect(new_child).to be_invalid
      end
    end

    context 'with unassigned parent start_date' do
      let(:new_child_start_date) { thirty_years_ago }
      let(:new_child_end_date) { mama_end_date }
      let(:mama_start_date) { nil }

      it do
        expect(new_child).to be_valid
      end
    end

    context 'with unassigned parent end_date' do
      let(:new_child_start_date) { mama_start_date }
      let(:new_child_end_date) { seventy_years_in_the_future }
      let(:mama_end_date) { nil }

      it do
        expect(new_child).to be_valid
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

  describe 'error messages' do
    let(:child_class) { OneParentChildCustom }
    let(:new_child_start_date) { mama_start_date - 3.days }
    let(:new_child_end_date) { mama_end_date + 5.days }

    it 'allows using custom error messages' do
      expect(new_child).not_to be_valid
      expect(new_child.errors.messages[:base]).to include('Custom error message')
    end
  end

  describe 'partial span validation' do
    let(:child_class) { TwoParentChildPartialSpanValidation }

    context 'skip_start_date_validation' do
      let(:new_child_start_date) { mama_start_date - 3.days }
      let(:new_child_end_date) { mama_end_date }

      it 'allows the start_date to be out of span' do
        expect(new_child).to be_valid
      end
    end

    context 'skip_end_date_validation' do
      let(:new_child_start_date) { papa_start_date }
      let(:new_child_end_date) { papa_end_date + 5.days }

      it 'allows the end_date to be out of span' do
        expect(new_child).to be_valid
      end
    end
  end
end
