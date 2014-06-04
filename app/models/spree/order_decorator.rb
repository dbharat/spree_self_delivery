Spree::Order.class_eval do
  belongs_to :self_delivery_point

  #attr_accessible :self_delivery_point_id

  spree_has_available_shipment = instance_method(:has_available_shipment)

  before_validation :set_ship_address

  state_machine do
    before_transition :to => :delivery do |order|
      if order.self_delivery? && !order.self_delivery_point
        order.shipping_method = nil
        order.save
      end
    end

    after_transition :to => :delivery do |order|
      if order.self_delivery?
        order.state = order.payment_required? ? :payment : :complete
        order.save
        order.state == :payment ? order.force_shippment_method_to_self_delivery : order.finalize! 
        #order.finalize! 
      end
    end
  end
  
  def self_delivery_point_id=(point_id)
    @self_delivery_point_id = point_id
  end

  def self_delivery?
    false if shipping_method_id.nil?
    shipping_method = Spree::ShippingMethod.find_by_id(shipping_method_id)
    shipping_method && shipping_method.self_delivery?
  end

  def force_shippment_method_to_self_delivery
    shipments.each do |s|
      s.shipping_methods.delete_all
      s.add_shipping_method(Spree::ShippingMethod.self_delivery, true)
      s.save
    end
  end


  private
  

  def set_ship_address
    if @self_delivery_point_id
      write_attribute(:self_delivery_point_id, @self_delivery_point_id)
      return if @self_delivery_point_id.to_i < 1 || !ship_address
      if sdp = Spree::SelfDeliveryPoint.find_by_id(@self_delivery_point_id)
        [:country, :state, :state_name, :city, :address1].each do |a|
          ship_address.send("#{a}=", sdp.send(a))
          bill_address.send("#{a}=", sdp.send(a))
        end
        ship_address.zipcode = '-'
        bill_address.zipcode = '-'
        self.shipping_method_id = Spree::ShippingMethod.self_delivery.id
      end
    end 
  end

  define_method :has_available_shipment do
    if self_delivery?
      return
    else
      spree_has_available_shipment.bind(self).call
    end
  end
end
