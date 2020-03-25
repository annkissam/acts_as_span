require 'spec_helper'

RSpec.describe "EndDatePropagator" do
  let(:end_date_propagator) do
    ActsAsSpan::EndDatePropagator.new(base_instance, skipped_classes)
  end

  let(:base_instance) do
    Base.create(end_date: initial_end_date)
  end
  let(:initial_end_date) { nil }

  let(:other_base_instance) do
    OtherBase.create(end_date: other_end_date)
  end
  let(:other_end_date) { nil }

  let(:skipped_classes) { [] }

  let!(:child_instance) do
    Child.create(
      base: base_instance,
      emancipation_date: child_end_date
    )
  end
  let(:child_end_date) { nil }

  let!(:dog_instance) do
    Dog.create(
      base: base_instance,
      end_date: dog_end_date
    )
  end
  let(:dog_end_date) { nil }

  let!(:bird_instance) do
    Bird.create(
      child: child_instance,
      end_date: child_end_date
    )
  end
  let(:bird_end_date) { nil }

  let(:tale_instance) do
    base_instance.tales.new(start_date: Date.current, end_date: nil)
  end

  describe '#call' do
    context 'without an end_date' do
      let(:object_instance) { double('copac') }

      it 'does not raise an error' do
        expect do
          ActsAsSpan::EndDatePropagator.new(object_instance).call
        end.not_to raise_error
      end
    end

    context 'updates children' do
      before do
        base_instance
        base_instance.end_date = end_date
      end

      context 'base_instance.end_date nil -> !nil' do
        let(:initial_end_date) { nil }
        let(:end_date) { Date.current }

        context 'child_end_date == initial_end_date' do
          let(:child_end_date) { initial_end_date }

          it 'propagates to the child_instance' do
            expect{ end_date_propagator.call }.to change{
              child_instance.reload.emancipation_date }
              .from(child_end_date).to(base_instance.end_date)
          end
        end

        context 'child_end_date >= initial_end_date' do
          let(:child_end_date) { end_date + 3 }

          it 'propagates to the child_instance' do
            expect{ end_date_propagator.call }.to change{
              child_instance.reload.emancipation_date}
              .from(child_end_date).to(base_instance.end_date)
          end
        end

        context 'child_end_date <= initial_end_date' do
          let(:child_end_date) { end_date - 3 }

          it 'does not propagate to the child_instance' do
            expect{ end_date_propagator.call }.not_to change{
              child_instance.reload.emancipation_date}
          end
        end
      end

      context 'base_instance.end_date !nil -> nil' do
        let(:initial_end_date) { Date.current }
        let(:end_date) { nil }
        let(:child_end_date) { initial_end_date }

        it 'does not propagate to the child_instance' do
          expect{ end_date_propagator.call }.not_to change{
            child_instance.reload.emancipation_date }
        end
      end

      context 'base_instance.end_date not changed' do
        let(:end_date) { initial_end_date }

        it 'does not propagate to the child_instance' do
          expect{ end_date_propagator.call }.not_to change{
            child_instance.reload.emancipation_date }
        end
      end

      context 'has access to all children via has_many associations' do
        let(:end_date) { Date.current }

        it 'changes the end_date of all child associations' do
          expect{ end_date_propagator.call }.to change{
            child_instance.reload.emancipation_date }.
            from(child_instance.emancipation_date).to(base_instance.end_date)
            .and change{ dog_instance.reload.end_date }
            .from(dog_instance.end_date).to(base_instance.end_date)
            .and change{ bird_instance.reload.end_date }
            .from(bird_instance.end_date).to(base_instance.end_date)
        end
      end
    end

    context 'when child record does not have end_date to update' do
      let!(:cat_owner_instance) do
        CatOwner.create(end_date: initial_end_date)
      end
      let!(:cat_instance) do
        Cat.create(cat_owner: cat_owner_instance)
      end
      let(:cat_end_date) { nil }
      let(:end_date) { Date.current }

      before do
        cat_owner_instance.end_date = end_date
      end

      it 'does not throw an error' do
        expect(cat_instance).not_to respond_to(:end_date)
        expect{ end_date_propagator.call }.not_to raise_error
      end
    end

    context 'when a class is skipped' do
      let(:end_date) { Date.current }
      let(:skipped_classes) { [Tale] }

      before do
        base_instance
        tale_instance.save!
        base_instance.end_date = end_date
      end

      it 'does not propagate to that class' do
        expect{ end_date_propagator.call }.not_to change{
          tale_instance.reload.end_date }
      end
    end
  end
end
