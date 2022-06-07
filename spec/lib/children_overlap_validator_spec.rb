# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActsAsSpan::ChildrenOverlapValidator do
  subject(:errors) { base.errors }

  let!(:base) { Base.create(start_date: Date.new(2000, 1,1)) }
  let!(:dog1) { Dog.create(start_date: dog1_start_date, end_date: dog1_end_date, base: base, age: dog1_age) }
  let!(:dog2) { Dog.create(start_date: dog2_start_date, end_date: dog2_end_date, base: base, age: dog2_age) }
  let(:dog1_age) { 3 }
  let(:dog2_age) { 5 }


  before { validator.validate(base) }

  context 'without instance_scope' do
    let(:validator) { ActsAsSpan::ChildrenOverlapValidator.new(scope: :dogs) }

    context 'when children overlap' do
      let(:dog1_start_date) { Date.new(2022, 1, 1) }
      let(:dog1_end_date) { Date.new(2022, 1, 30) }
      let(:dog2_start_date) { Date.new(2022, 1, 15) }
      let(:dog2_end_date) { Date.new(2022, 2, 15) }

      it { is_expected.not_to be_empty }
    end

    context 'when children do not overlap' do
      let(:dog1_start_date) { Date.new(2022, 1, 1) }
      let(:dog1_end_date) { Date.new(2022, 1, 30) }
      let(:dog2_start_date) { Date.new(2022, 2, 15) }
      let(:dog2_end_date) { Date.new(2022, 2, 28) }

      it { is_expected.to be_empty }
    end
  end

  context 'with instance_scope' do
    let(:validator) { ActsAsSpan::ChildrenOverlapValidator.new(scope: :dogs, instance_scope: ->(child) { child.age == 5 }) }

    context 'when children overlap' do
      let(:dog1_start_date) { Date.new(2022, 1, 1) }
      let(:dog1_end_date) { Date.new(2022, 1, 30) }
      let(:dog2_start_date) { Date.new(2022, 1, 15) }
      let(:dog2_end_date) { Date.new(2022, 2, 15) }

      context 'when overlapping children do not belong to same scope' do
        it { is_expected.to be_empty }
      end

      context 'when overlapping children belong to same scope' do
        let(:dog1_age) { 5 }

        it { is_expected.not_to be_empty }
      end
    end
  end
end
