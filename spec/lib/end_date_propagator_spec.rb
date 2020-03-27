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
    base_instance.tales.create(start_date: Date.current, end_date: nil)
  end

  describe '@errors_cache' do
    let(:base_start_date) { Date.current - 7 }
    let(:initial_end_date) { nil }
    let(:end_date) { Date.current }

    let(:child_start_date) { base_start_date + 1 }
    let!(:child_instance) do
      Child.create(
        base: base_instance,
        date_of_birth: child_start_date,
        emancipation_date: child_end_date
      )
    end
    let(:bird_start_date) { child_start_date + 1 }
    let!(:bird_instance) do
      Bird.create(
        child: child_instance,
        start_date: bird_start_date,
        end_date: bird_end_date
      )
    end

    before do
      base_instance.start_date = base_start_date
      base_instance.save!
      base_instance.end_date = end_date
    end

    context 'when all child records are successfully saved' do
      it 'the parent record does not have any errors' do
        expect(
          end_date_propagator.call(transaction: false).errors.full_messages
        ).to be_empty
      end
    end

    context 'when one grandchild record is not valid' do
      before do
        bird_instance.start_date = child_start_date - 1
        bird_instance.save(validate: false)
      end
      it "the parent shows that grandchild's errors" do
        expect(
          end_date_propagator.call(transaction: false).errors.values.join
        ).to include(
          I18n.t(
            'not_within_parent_date_span',
            parent: 'Child',
            scope: %i[activerecord errors messages]
          )
        )
      end
    end

    context 'when multiple child records are not valid' do
      before do
        bird_instance.start_date = child_start_date - 1
        bird_instance.save(validate: false)
      end
      it "the parent gains all children's errors" do
        expect(
          end_date_propagator.call(transaction: false).errors.full_messages
        ).not_to be_empty
      end
    end
  end

  describe '#call' do
    describe 'options' do
      context 'when both :save! and :save options are true' do
        let(:options) { { save: true, save!: true } }
        it 'raises an error' do
          expect{ end_date_propagator.call(options) }
            .to raise_error(ArgumentError)
        end
      end

      context 'when :transaction is not set' do
        let(:options) { {} }
        before do
          allow(end_date_propagator).to receive(:call_with_transaction)
        end
        it 'defaults to using a transaction' do
          end_date_propagator.call(options)
          expect(end_date_propagator).to have_received(:call_with_transaction)
        end
      end

      context 'when :transaction is true' do
        let(:options) { { transaction: true } }
        before do
          allow(end_date_propagator).to receive(:call_with_transaction)
        end
        it 'calls the transaction wrapping method' do
          end_date_propagator.call(options)
          expect(end_date_propagator)
            .to have_received(:call_with_transaction)
        end
      end

      context 'when :transaction is false' do
        let(:options) { { transaction: false } }
        before do
          allow(end_date_propagator).to receive(:call_with_transaction)
        end
        it 'does not call the transaction wrapping method' do
          end_date_propagator.call(options)
          expect(end_date_propagator)
            .not_to have_received(:call_with_transaction)
        end
      end

      context 'when neither :save nor :save! is set' do
        let(:options) { {} }
          before do
            allow(base_instance).to receive(:save).and_return(true)
          end
        it 'defaults to not saving @object' do
          end_date_propagator.call(options)
          expect(base_instance).not_to have_received(:save)
        end
      end

      context 'when any save option is true' do
        context '(:save)' do
          let(:options) { { save: true } }
          before do
            allow(base_instance).to receive(:save).and_return(true)
          end
          it 'calls :save on @object' do
            end_date_propagator.call(options)
            expect(base_instance).to have_received(:save)
          end
        end

        context '(:save!)' do
          before do
            allow(base_instance).to receive(:save!).and_return(base_instance)
          end
          let(:options) { { save!: true } }
          it 'calls :save! on @object' do
            end_date_propagator.call(options)
            expect(base_instance).to have_received(:save!)
          end
        end
      end

      context 'when any save option is false' do
        before do
          allow(base_instance).to receive(:save).and_return(true)
          allow(base_instance).to receive(:save!).and_return(base_instance)
        end
        context '(:save)' do
          let(:options) { { save: false } }
          it 'does not attempt to save @object' do
            end_date_propagator.call(options)
            expect(base_instance).not_to have_received(:save)
          end
        end
        context '(:save!)' do
          let(:options) { { save!: false } }
          it 'does not attempt to save @object' do
            end_date_propagator.call(options)
            expect(base_instance).not_to have_received(:save!)
          end
        end
      end
    end
  end

  describe '#call_sans_transaction' do
    let(:options) do
      { transaction: false, save: save_option, save!: save_bang_option }
    end
    let(:save_option) { nil }
    let(:save_bang_option) { nil }

    context 'without an end_date' do
      let(:object_instance) { SpannableModel.new }

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
            expect{ end_date_propagator.call(options) }.to change{
              child_instance.reload.emancipation_date }
              .from(child_end_date).to(base_instance.end_date)
          end
        end

        context 'child_end_date >= initial_end_date' do
          let(:child_end_date) { end_date + 3 }

          it 'propagates to the child_instance' do
            expect{ end_date_propagator.call(options) }.to change{
              child_instance.reload.emancipation_date}
              .from(child_end_date).to(base_instance.end_date)
          end
        end

        context 'child_end_date <= initial_end_date' do
          let(:child_end_date) { end_date - 3 }

          it 'does not propagate to the child_instance' do
            expect{ end_date_propagator.call(options) }.not_to change{
              child_instance.reload.emancipation_date}
          end
        end

        context 'when a child cannot have its end date updated' do
          before do
            # add a "within parent date span" error to child
            base_instance.start_date = Date.current - 1
            child_instance.date_of_birth = Date.current - 2
            child_instance.save(validate: false)
          end

          it "the parent's end date is not updated" do
            expect{ end_date_propagator.call(options) }.to change{
              base_instance.errors[:base]
            }.from([])
          end

          context 'and the child is the child of a child' do
            before do
            end

            it "the parent's end date is not updated" do
              expect{ end_date_propagator.call(options) }.not_to change{
                base_instance.reload.end_date
              }
            end
          end
        end
      end

      context 'base_instance.end_date !nil -> nil' do
        let(:initial_end_date) { Date.current }
        let(:end_date) { nil }
        let(:child_end_date) { initial_end_date }

        it 'does not propagate to the child_instance' do
          expect{ end_date_propagator.call(options) }.not_to change{
            child_instance.reload.emancipation_date }
        end
      end

      context 'base_instance.end_date not changed' do
        let(:end_date) { initial_end_date }

        it 'does not propagate to the child_instance' do
          expect{ end_date_propagator.call(options) }.not_to change{
            child_instance.reload.emancipation_date }
        end
      end

      context 'has access to all children via has_many associations' do
        let(:end_date) { Date.current }

        it 'changes the end_date of all child associations' do
          expect{ end_date_propagator.call(options) }.to change{
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
        expect{ end_date_propagator.call(options) }.not_to raise_error
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
        expect{ end_date_propagator.call(options) }.not_to change{
          tale_instance.reload.end_date }
      end
    end

    context 'when :save is true' do
      let(:save_option) { true }

      let(:initial_end_date) { Date.current + 7 }
      let(:end_date) { Date.current + 14 }

      before do
        base_instance
        base_instance.end_date = end_date
      end

      context 'and @object is valid' do
        before { allow(base_instance).to receive(:valid?).and_return(true) }
        it "commits @object's changes to the database" do
          expect{ end_date_propagator.call(options) }
            .to change{ Base.find(base_instance.id).end_date }
        end
      end

      context 'and @object is not valid' do
        before { allow(base_instance).to receive(:valid?).and_return(false) }
        it "does not commit @object's changes to the database" do
          expect{ end_date_propagator.call(options) }
            .not_to change{ Base.find(base_instance.id).end_date }
        end
      end
    end

    context 'when :save! is true' do
      let(:save_bang_option) { true }

      let(:initial_end_date) { Date.current + 7 }
      let(:end_date) { Date.current + 14 }

      before do
        base_instance
        base_instance.end_date = end_date
      end

      context 'and @object is valid' do
        before { allow(base_instance).to receive(:valid?).and_return(true) }
        it "commits @object's changes to the database" do
          expect{ end_date_propagator.call(options) }
            .to change{ Base.find(base_instance.id).end_date }
        end
      end

      context 'and @object is not valid' do
        before { allow(base_instance).to receive(:valid?).and_return(false) }
        it "allows @object.save! to raise its error" do
          expect{ end_date_propagator.call(options) }
            .to raise_error( ActiveRecord::RecordInvalid )
        end
      end
    end
  end

  describe '#call_with_transaction' do
    let(:options) do
      { transaction: true, save: save_option, save!: save_bang_option }
    end
    let(:save_option) { nil }
    let(:save_bang_option) { nil }

    let(:base_start_date) { Date.current - 7 }
    let(:initial_end_date) { nil }
    let(:end_date) { Date.current }

    let(:child_start_date) { base_start_date + 1 }
    let!(:child_instance) do
      Child.create(
        base: base_instance,
        date_of_birth: child_start_date,
        emancipation_date: child_end_date
      )
    end
    let(:bird_start_date) { child_start_date + 1 }
    let!(:bird_instance) do
      Bird.create(
        child: child_instance,
        start_date: bird_start_date,
        end_date: bird_end_date
      )
    end

    context 'when any child record is invalid' do
      before do
        bird_instance.start_date = child_start_date - 1
        bird_instance.save(validate: false)
        base_instance.end_date = end_date
      end
      it 'does not update any end dates' do
        expect{ end_date_propagator.call(options) }.to not_change{
          Base.find(base_instance.id).end_date }.and not_change{
            Bird.find(bird_instance.id).end_date }.and not_change{
              Child.find(child_instance.id).emancipation_date }.and not_change{
                Dog.find(dog_instance.id).end_date }.and not_change{
                  Tale.find(tale_instance.id).end_date }
      end
    end
  end
end
