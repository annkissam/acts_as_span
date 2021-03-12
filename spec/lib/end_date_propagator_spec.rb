require 'spec_helper'

RSpec.describe ActsAsSpan::EndDatePropagator do
  let(:end_date_propagator) do
    ActsAsSpan::EndDatePropagator.new(
      base_instance,
      skipped_classes: skipped_classes,
      include_errors: include_errors,
    )
  end

  let(:base_instance) do
    Base.create(end_date: initial_end_date)
  end

  let(:include_errors) { true }
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
          end_date_propagator.call.errors.full_messages
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
          end_date_propagator.call.errors.full_messages.join
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
      context 'when include_errors = true (default)' do
        before do
          child_instance.date_of_birth = base_instance.span.start_date - 1
          child_instance.save(validate: false)
          bird_instance.start_date = child_instance.span.start_date - 1
          bird_instance.save(validate: false)
        end
        it "the parent gains all children's errors" do
          expect(
            end_date_propagator.call.errors.full_messages.join
          ).to include(
            I18n.t(
              'not_within_parent_date_span',
              parent: 'Child',
              scope: %i[activerecord errors messages]
            )
          ).and include(
            I18n.t(
              'not_within_parent_date_span',
              parent: 'Base',
              scope: %i[activerecord errors messages]
            )
          )
        end
      end

      context 'when include_errors = false' do
        let(:include_errors) { false }

        it 'does not push any child errors' do
          expect(end_date_propagator.call.errors.full_messages).to be_empty
        end
      end
    end
  end

  describe '.call' do
    subject(:result) do
      ActsAsSpan::EndDatePropagator.call(obj, call_options)
    end
    let(:obj) { base_instance }

    context 'when no skipped classes are passed' do
      let(:call_options) { {} }

      it 'forwards the correct arguments to :new' do
        expect(ActsAsSpan::EndDatePropagator)
          .to receive(:new).with(obj, call_options).and_call_original
        expect(result).to eq(obj)
      end
    end

    context 'when skipped classes are passed' do
      let(:call_options) { { skipped_classes: ['bungus'] } }

      it 'forwards the correct arguments to :new' do
        expect(ActsAsSpan::EndDatePropagator)
          .to receive(:new).with(obj, call_options).and_call_original
        expect(result).to eq(obj)
      end
    end
  end

  describe '#call' do
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

        context 'when a child cannot have its end date updated' do
          before do
            # add a "within parent date span" error to child
            base_instance.start_date = Date.current - 1
            child_instance.date_of_birth = Date.current - 2
            child_instance.save(validate: false)
          end

          it "the parent's end date is not updated" do
            expect{ end_date_propagator.call }.to change{
              base_instance.errors[:base]
            }.from([])
          end

          context 'and the child is the child of a child' do
            before do
            end

            it "the parent's end date is not updated" do
              expect{ end_date_propagator.call }.not_to change{
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

    context 'when the record already has a validation that would be added' do
      let(:end_date) { Date.current }

      before do
        base_instance.save!
        base_instance.end_date = end_date
        base_instance.errors.add(:base, 'Child is bad')

        child_instance.manual_invalidation = true
        child_instance.save(validate: false)

        # add the error that would be added by the child's propagation
        base_instance.errors.add(
          :base,
          "Base could not propagate Emancipation date to Child:\nChild is bad",
        )
      end

      it 'does not add the duplicate error' do
        expect { end_date_propagator.call }
          .not_to(change(base_instance, :errors))
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
