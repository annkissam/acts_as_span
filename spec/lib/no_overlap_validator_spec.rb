require 'spec_helper'
require 'has_siblings'

RSpec.describe ActsAsSpan::NoOverlapValidator do
  let!(:brother) do
    child_class.create(
      start_date: brother_start_date,
      end_date: brother_end_date,
      mama: mama)
  end

  let!(:sister) do
    child_class.create(
      start_date: sister_start_date,
      end_date: sister_end_date,
      mama: mama)
  end

  let!(:brother_from_another_mother) do
    child_class.create(
      start_date: new_child_start_date,
      end_date: new_child_end_date,
      mama: other_mama)
  end

  let(:new_child) do
    child_class.new(
      start_date: new_child_start_date,
      end_date: new_child_end_date,
      mama: mama)
  end

  let(:mama) { Mama.create }
  let(:other_mama) { Mama.create }
  let(:papa) { Papa.create }

  let(:brother_start_date) { Date.current - 2 }
  let(:brother_end_date) { Date.current - 1  }

  let(:sister_start_date) { Date.current + 2 }
  let(:sister_end_date) { Date.current + 3 }

  let(:all_siblings) { [brother, sister, brother_from_another_mother] }

  describe 'instance_scope' do
    let(:child_class) { OneParentChild }

    let(:new_child_start_date) { Date.current - 2 }
    let(:new_child_end_date) { Date.current + 3 }

    before { new_child.favorite = favorite }

    context 'when instance_scope evaluates to false' do
      let(:favorite) { false }
      it 'skips validation on the record for which instance_scope is false' do
        expect(new_child).to be_valid
      end
    end

    context 'when instance_scope evaluates to true' do
      let(:favorite) { true }
      it 'validates normally' do
        expect(new_child).not_to be_valid
      end
    end
  end

  describe 'an object with a single parent' do
    let(:child_class) { OneParentChild }

    context 'valid cases' do
      let(:new_child_start_date) { Date.current }
      let(:new_child_end_date) { Date.current + 1 }

      it 'allows overlapping spans on for associated records with different parents' do
        expect(new_child).to be_valid
      end
    end

    context 'invalid cases' do
      let(:new_child_start_date) { Date.current - 2 }
      let(:new_child_end_date) { Date.current + 3 }

      it 'does not allow overlapping spans siblings with same parents' do
        expect(new_child).not_to be_valid
      end
    end
  end

  describe 'an object with multiple parents' do
    let(:child_class) { TwoParentChild }

    before do
      all_siblings.each do |sibling|
        sibling.update(papa: papa)
      end

      new_child.papa = papa
    end

    context 'valid cases' do
      let(:new_child_start_date) { brother_end_date + 1 }
      let(:new_child_end_date) { sister_start_date - 1 }

      it 'allows overlapping spans on for associated records with different parents' do
        expect(new_child).to be_valid
      end
    end

    context 'invalid cases' do
      let(:new_child_start_date) { brother_start_date }
      let(:new_child_end_date) { sister_end_date }

      it 'does not allow overlapping spans siblings with same parents' do
        expect(new_child).not_to be_valid
      end
    end
  end

  describe 'error messages' do
    let(:child_class) { OneParentChildCustom }
    let(:new_child_start_date) { sister_start_date }
    let(:new_child_end_date) { sister_end_date }
    it 'allows using custom error messages' do
      expect(new_child).not_to be_valid
      expect(new_child.errors.messages[:base]).to include('Custom error message')
    end
  end
end
