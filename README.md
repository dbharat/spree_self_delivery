SpreeSelfDelivery
=================


Installation
-------

    Add to gemfile: `gem 'spree_self_delivery', :git => 'git://github.com/secoint/spree_self_delivery.git'`
   
    Run `bundle install`
    Run `rails g spree_self_delivery:install`
    Run `rake db:migrate`

    Create ShippingMethod with `self delivery` calculator and display_on = back_end
    Go to `/admin/self_delivery_points` and create one or more self delivery points

##### Note

``` 
  rails console
  Spree::Config[:address_requires_state] = false
  
  initializers/self_delivery.rb:
  Spree::PermittedAttributes.checkout_attributes << :self_delivery_point_id
```
If you are using spree_address_book gem it should be specified before spree_self_delivery in Gemfile
