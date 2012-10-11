Spree::Shipment.class_eval do
  belongs_to :temando_quote

  state_machines[:state] = nil # reset original state machine to start from scratch.

  # We know that there will be preexisting methods from the original Spree state machine.
  # Until there's a better API to update a state machine, just ignore the conflicts by
  # overriding the old ones. Ideally the state_machine gem would provide a way to delete
  # an existing machine.
  StateMachine::Machine.ignore_method_conflicts = true

  # This is a modified version of the original spree shipment state machine
  # with the indicated changes.
  state_machine :initial => 'pending', :use_transactions => false do
    event :ready do
      transition :from => 'pending', :to => 'ready'
    end
    event :pend do
      transition :from => 'ready', :to => 'pending'
    end
    event :ship do
      transition :from => 'ready', :to => 'shipped'
    end

    before_transition 'ready' => any - 'ready', :do => :prevent_if_booked
    after_transition :to => 'ready',   :do => :after_ready
    after_transition :to => 'shipped', :do => :after_ship
  end


  def prevent_if_booked
    raise "Can not cancel a booked Temando quote" if self.temando_quote.present? && self.temando_quote.booked?
  end

  def after_ready
    if self.temando_quote.blank? && self.order.temando_quote.present? then
      self.temando_quote = self.order.temando_quote
    end

    if self.temando_quote.present? then
      # Confirm the Quote booking
      self.temando_quote.book!
    end
  end
end
