module ApplicationHelper
  def setup_registrant_choices(registrant)
    EventChoice.all.each do |ec|
      if registrant.registrant_choices.where({:event_choice_id => ec.id}).empty?
        new_cc = registrant.registrant_choices.build
        new_cc.event_choice_id = ec.id
      end
    end
    Event.all.each do |ev|
      if registrant.registrant_event_sign_ups.select { |resu| resu.event_id == ev.id}.empty?
        new_resu = registrant.registrant_event_sign_ups.build
        new_resu.event = ev
      end
    end
    registrant
  end

  def mixpanel?
    !ENV['MIXPANEL_TOKEN'].nil?
  end

  def numeric?(val)
    Float(val) != nil rescue false
  end
end
