require 'faker'

puts "🌱 Seeding database..."

# Only clear data in development environment
if Rails.env.development?
  puts "🧹 Clearing existing data..."
  
  ActiveRecord::Base.transaction do
    ActivityLog.delete_all
    Payment.delete_all
    RepairStatus.delete_all
    RepairTicket.delete_all
    Device.unscoped.delete_all
    Customer.unscoped.delete_all
    User.delete_all
  end
  
  puts "✓ Existing data cleared"
end

# Helper method to generate South African phone numbers
def south_african_phone
  "+27#{rand(60..89)}#{rand(100..999)}#{rand(1000..9999)}"
end

# Helper method to generate South African ID number
def south_african_id
  year = rand(1960..2003)
  month = rand(1..12).to_s.rjust(2, '0')
  day = rand(1..28).to_s.rjust(2, '0')
  sequence = rand(0..9999).to_s.rjust(4, '0')
  citizenship = rand(0..1)
  "#{year.to_s[-2..-1]}#{month}#{day}#{sequence}0#{citizenship}#{rand(0..9)}"
end

# Device configurations
DEVICE_BRANDS = {
  phone: ['Samsung', 'Apple', 'Huawei', 'Xiaomi', 'Nokia'],
  tablet: ['Apple', 'Samsung', 'Huawei', 'Lenovo'],
  laptop: ['HP', 'Dell', 'Lenovo', 'Apple', 'Asus'],
  desktop: ['Dell', 'HP', 'Lenovo', 'Custom Build']
}

PHONE_MODELS = {
  'Samsung' => ['Galaxy S21', 'Galaxy S22', 'Galaxy A52', 'Galaxy A72', 'Galaxy Note 20'],
  'Apple' => ['iPhone 12', 'iPhone 13', 'iPhone 14', 'iPhone SE', 'iPhone 11'],
  'Huawei' => ['P40 Pro', 'P30 Lite', 'Nova 7i', 'Y9a', 'Mate 40'],
  'Xiaomi' => ['Redmi Note 10', 'Redmi Note 11', 'Mi 11', 'Poco X3', 'Poco F3'],
  'Nokia' => ['Nokia 8.3', 'Nokia 7.2', 'Nokia 5.4', 'Nokia 3.4', 'Nokia 2.4']
}

TABLET_MODELS = {
  'Apple' => ['iPad Pro 11"', 'iPad Air', 'iPad 9th Gen', 'iPad Mini'],
  'Samsung' => ['Galaxy Tab S7', 'Galaxy Tab S8', 'Galaxy Tab A8', 'Galaxy Tab A7'],
  'Huawei' => ['MatePad Pro', 'MatePad 11', 'MediaPad M5', 'MatePad T10'],
  'Lenovo' => ['Tab P11', 'Tab M10', 'Tab P12 Pro', 'Yoga Tab 11']
}

LAPTOP_MODELS = {
  'HP' => ['Pavilion 15', 'ProBook 450', 'EliteBook 840', 'Envy 13', 'Spectre x360'],
  'Dell' => ['Inspiron 15', 'Latitude 5420', 'XPS 13', 'Vostro 3500', 'Precision 3560'],
  'Lenovo' => ['ThinkPad T14', 'IdeaPad 3', 'Yoga 7i', 'Legion 5', 'ThinkBook 15'],
  'Apple' => ['MacBook Air M1', 'MacBook Air M2', 'MacBook Pro 13"', 'MacBook Pro 16"'],
  'Asus' => ['VivoBook 15', 'ZenBook 14', 'ROG Strix G15', 'TUF Gaming', 'ExpertBook']
}

DESKTOP_MODELS = {
  'Dell' => ['OptiPlex 7090', 'Inspiron Desktop', 'XPS Desktop', 'Vostro Desktop'],
  'HP' => ['EliteDesk 800', 'ProDesk 400', 'Pavilion Desktop', 'OMEN Desktop'],
  'Lenovo' => ['ThinkCentre M90', 'IdeaCentre 3', 'ThinkStation P340', 'Legion Tower'],
  'Custom Build' => ['Gaming PC', 'Workstation', 'Office PC', 'Budget Build']
}

# Fault descriptions
FAULT_DESCRIPTIONS = [
  "Screen cracked, display not working properly",
  "Water damage, device won't power on",
  "Battery drains extremely quickly",
  "Charging port loose/not working",
  "Software issues, device keeps freezing",
  "Speaker not working, no sound output",
  "Microphone not working during calls",
  "Camera not functioning properly",
  "Overheating issues",
  "Touch screen not responsive",
  "Home button not working",
  "Power button stuck/not responding",
  "WiFi connection issues",
  "Bluetooth not working",
  "Device stuck in boot loop",
  "Screen flickering",
  "Back glass cracked",
  "Network connectivity issues",
  "Apps crashing frequently",
  "Storage full, device running slow",
  "Face ID/fingerprint sensor not working",
  "Volume buttons not responding",
  "SIM card not detected",
  "Random shutdowns",
  "Keyboard not working properly",
  "Trackpad unresponsive",
  "Display hinge broken",
  "Fan making loud noise",
  "Hard drive failure",
  "RAM upgrade needed"
]

# Accessories
ACCESSORIES = [
  "Charger",
  "Charging cable",
  "Earphones",
  "Phone case",
  "Screen protector",
  "Stylus pen",
  "Original box",
  "SIM card tray",
  "Memory card",
  "Laptop bag",
  "Mouse",
  "Keyboard"
]

# Status notes templates
STATUS_NOTES = {
  pending: [
    "Ticket created, awaiting initial assessment",
    "Received device, logged accessories",
    "Customer confirmed fault description",
    "Added to repair queue"
  ],
  in_progress: [
    "Started diagnostic tests",
    "Identified faulty component",
    "Disassembled device for repair",
    "Replacement part installed",
    "Running system tests",
    "Almost complete, final testing"
  ],
  waiting_for_parts: [
    "Ordered replacement screen",
    "Waiting for battery delivery",
    "Part on backorder, ETA 3-5 days",
    "Sourcing compatible replacement",
    "Supplier confirmed shipment"
  ],
  completed: [
    "Repair completed successfully",
    "All tests passed",
    "Device fully functional",
    "Quality check completed",
    "Ready for customer collection",
    "Cleaned and packaged"
  ],
  collected: [
    "Customer collected device",
    "Device handed over to customer",
    "Customer satisfied with repair"
  ],
  cancelled: [
    "Customer requested cancellation",
    "Repair not economical",
    "Customer unreachable",
    "Part unavailable"
  ]
}

begin
  ActiveRecord::Base.transaction do
    # ==========================================
    # 1. CREATE USERS
    # ==========================================
    print "✓ Creating users... "
  
  admin = User.create!(
    email: 'admin@capetech.com',
    password: 'Admin123!',
    first_name: 'Admin',
    last_name: 'User',
    role: :admin,
    active: true
  )
  
  technician = User.create!(
    email: 'tech@capetech.com',
    password: 'Tech123!',
    first_name: 'John',
    last_name: 'Tech',
    role: :technician,
    active: true
  )
  
  cashier = User.create!(
    email: 'cashier@capetech.com',
    password: 'Cashier123!',
    first_name: 'Sarah',
    last_name: 'Cash',
    role: :cashier,
    active: true
  )
  
  puts "(3 created)"
  
  # ==========================================
  # 2. CREATE CUSTOMERS
  # ==========================================
  print "✓ Creating customers... "
  
  customers = []
  25.times do |i|
    # Make 2-3 customers inactive
    is_active = i < 22
    
    # About 80% have email, 20% phone only
    has_email = rand < 0.8
    
    customers << Customer.create!(
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      email: has_email ? Faker::Internet.email : nil,
      phone: south_african_phone,
      address: rand < 0.7 ? "#{Faker::Address.street_address}, #{Faker::Address.city}, #{Faker::Address.zip}" : nil,
      id_number: rand < 0.6 ? south_african_id : nil,
      active: is_active
    )
  end
  
  puts "(#{customers.count} created)"
  
  # ==========================================
  # 3. CREATE DEVICES
  # ==========================================
  print "✓ Creating devices... "
  
  devices = []
  device_type_distribution = [
    [:phone, 20],    # 50% phones (20 devices)
    [:tablet, 8],    # 20% tablets (8 devices)
    [:laptop, 8],    # 20% laptops (8 devices)
    [:desktop, 2],   # 5% desktops (2 devices)
    [:other, 2]      # 5% other (2 devices)
  ]
  
  device_type_distribution.each do |type, count|
    count.times do
      customer = customers.sample
      
      if type == :other
        brand = Faker::Company.name
        model = "Generic Device"
      else
        brand = DEVICE_BRANDS[type].sample
        
        case type
        when :phone
          model = PHONE_MODELS[brand]&.sample || "#{brand} Phone"
        when :tablet
          model = TABLET_MODELS[brand]&.sample || "#{brand} Tablet"
        when :laptop
          model = LAPTOP_MODELS[brand]&.sample || "#{brand} Laptop"
        when :desktop
          model = DESKTOP_MODELS[brand]&.sample || "#{brand} Desktop"
        end
      end
      
      devices << Device.create!(
        customer: customer,
        device_type: type,
        brand: brand,
        model: model,
        serial_number: rand < 0.6 ? "SN#{SecureRandom.hex(8).upcase}" : nil,
        imei: (type == :phone && rand < 0.7) ? "#{rand(100000000000000..999999999999999)}" : nil,
        password_pin: rand < 0.4 ? "#{rand(1000..9999)}" : nil,
        notes: rand < 0.3 ? Faker::Lorem.sentence : nil
      )
    end
  end
  
  puts "(#{devices.count} created)"
  
  # ==========================================
  # 4. CREATE REPAIR TICKETS
  # ==========================================
  print "✓ Creating repair tickets... "
  
  tickets = []
  status_distribution = {
    pending: 6,              # 10%
    in_progress: 12,         # 20%
    waiting_for_parts: 9,    # 15%
    completed: 18,           # 30%
    collected: 12,           # 20%
    cancelled: 3             # 5%
  }
  
  priority_distribution = {
    urgent: 6,    # 10%
    high: 12,     # 20%
    medium: 30,   # 50%
    low: 12       # 20%
  }
  
  # Flatten distributions
  statuses = status_distribution.flat_map { |status, count| [status] * count }
  priorities = priority_distribution.flat_map { |priority, count| [priority] * count }
  
  60.times do |i|
    device = devices.sample
    status = statuses[i]
    priority = priorities[i]
    
    # Assign technician to in_progress and waiting_for_parts tickets
    assigned_tech = [:in_progress, :waiting_for_parts].include?(status) ? technician : nil
    
    # Random date within last 30 days
    created_date = rand(30).days.ago + rand(24).hours
    
    # Estimated cost
    estimated_cost = rand(100..2000).round(-1) # Round to nearest 10
    
    # Actual cost for completed/collected tickets
    actual_cost = [:completed, :collected].include?(status) ? (estimated_cost * (0.8 + rand * 0.4)).round(-1) : nil
    
    # Completed timestamp for completed/collected tickets
    completed_at = [:completed, :collected].include?(status) ? created_date + rand(1..10).days : nil
    
    # Collected timestamp for collected tickets
    collected_at = status == :collected ? completed_at + rand(1..5).days : nil
    
    # Random accessories (1-4 items or none)
    accessories_count = rand < 0.7 ? rand(1..4) : 0
    accessories = accessories_count > 0 ? ACCESSORIES.sample(accessories_count).join(", ") : nil
    
    ticket = RepairTicket.create!(
      customer: device.customer,
      device: device,
      fault_description: FAULT_DESCRIPTIONS.sample,
      status: status,
      priority: priority,
      assigned_technician: assigned_tech,
      estimated_cost: estimated_cost,
      actual_cost: actual_cost,
      accessories_received: accessories,
      completed_at: completed_at,
      collected_at: collected_at,
      created_at: created_date,
      updated_at: created_date
    )
    
    tickets << ticket
  end
  
  puts "(#{tickets.count} created)"
  
  # ==========================================
  # 5. CREATE REPAIR STATUSES
  # ==========================================
  print "✓ Creating repair statuses... "
  
  repair_statuses = []
  
  tickets.each do |ticket|
    # Determine status progression
    status_progression = case ticket.status
    when 'pending'
      [:pending]
    when 'in_progress'
      [:pending, :in_progress]
    when 'waiting_for_parts'
      [:pending, :in_progress, :waiting_for_parts]
    when 'completed'
      rand < 0.5 ? [:pending, :in_progress, :completed] : [:pending, :in_progress, :waiting_for_parts, :completed]
    when 'collected'
      rand < 0.5 ? [:pending, :in_progress, :completed, :collected] : [:pending, :in_progress, :waiting_for_parts, :completed, :collected]
    when 'cancelled'
      [:pending, :cancelled]
    end
    
    # Create status entries
    time_cursor = ticket.created_at
    status_progression.each_with_index do |status, index|
      # Pick appropriate user
      changed_by = status == :pending ? admin : technician
      
      # Get appropriate note
      notes = STATUS_NOTES[status].sample
      
      repair_statuses << RepairStatus.create!(
        repair_ticket: ticket,
        status: status,
        notes: notes,
        changed_by: changed_by,
        created_at: time_cursor,
        updated_at: time_cursor
      )
      
      # Increment time for next status (1-3 days)
      time_cursor += rand(1..3).days + rand(24).hours
    end
  end
  
  puts "(#{repair_statuses.count} created)"
  
  # ==========================================
  # 6. CREATE PAYMENTS
  # ==========================================
  print "✓ Creating payments... "
  
  payments = []
  payment_method_distribution = [:cash, :cash, :card, :card, :bank_transfer, :other]
  
  # Create payments for completed and collected tickets
  payable_tickets = tickets.select { |t| ['completed', 'collected'].include?(t.status) }
  
  payable_tickets.each do |ticket|
    total_cost = ticket.actual_cost || ticket.estimated_cost
    
    # 70% fully paid, 30% partially paid
    if rand < 0.7
      # Full payment
      method = payment_method_distribution.sample
      payment_date = ticket.completed_at + rand(0..2).days
      
      reference = [:card, :bank_transfer].include?(method) ? "REF#{SecureRandom.hex(6).upcase}" : nil
      
      payments << Payment.create!(
        repair_ticket: ticket,
        amount: total_cost,
        payment_method: method,
        payment_date: payment_date,
        reference_number: reference,
        received_by: [cashier, admin].sample,
        notes: rand < 0.3 ? "Payment received in full" : nil,
        created_at: payment_date,
        updated_at: payment_date
      )
    else
      # Partial payments (2-3 payments)
      num_payments = rand(2..3)
      remaining = total_cost
      
      num_payments.times do |i|
        # Last payment is remaining amount
        amount = i == num_payments - 1 ? remaining : (remaining * rand(0.3..0.5)).round(2)
        remaining -= amount
        
        method = payment_method_distribution.sample
        payment_date = ticket.completed_at + (i * rand(1..3)).days
        
        reference = [:card, :bank_transfer].include?(method) ? "REF#{SecureRandom.hex(6).upcase}" : nil
        
        payments << Payment.create!(
          repair_ticket: ticket,
          amount: amount,
          payment_method: method,
          payment_date: payment_date,
          reference_number: reference,
          received_by: [cashier, admin].sample,
          notes: i == num_payments - 1 ? "Final payment" : "Partial payment #{i + 1}",
          created_at: payment_date,
          updated_at: payment_date
        )
      end
    end
  end
  
  puts "(#{payments.count} created)"
  
  # ==========================================
  # 7. CREATE ACTIVITY LOGS
  # ==========================================
  print "✓ Creating activity logs... "
  
  activity_logs = []
  
  # Log ticket creations
  tickets.each do |ticket|
    activity_logs << ActivityLog.create!(
      user: admin,
      repair_ticket: ticket,
      action_type: 'ticket_created',
      description: "Repair ticket #{ticket.ticket_number} created for #{ticket.customer.full_name}",
      metadata: {
        ticket_number: ticket.ticket_number,
        device: "#{ticket.device.brand} #{ticket.device.model}",
        priority: ticket.priority
      },
      created_at: ticket.created_at,
      updated_at: ticket.created_at
    )
  end
  
  # Log status updates
  repair_statuses.each do |repair_status|
    next if repair_status.status == 'pending' # Skip initial status
    
    activity_logs << ActivityLog.create!(
      user: repair_status.changed_by,
      repair_ticket: repair_status.repair_ticket,
      action_type: 'status_updated',
      description: "Status changed to #{repair_status.status.humanize}",
      metadata: {
        old_status: repair_status.repair_ticket.repair_statuses.where('created_at < ?', repair_status.created_at).last&.status,
        new_status: repair_status.status,
        notes: repair_status.notes
      },
      created_at: repair_status.created_at,
      updated_at: repair_status.created_at
    )
  end
  
  # Log technician assignments
  tickets.select { |t| t.assigned_technician.present? }.each do |ticket|
    # Find when ticket went to in_progress
    in_progress_status = ticket.repair_statuses.find_by(status: :in_progress)
    timestamp = in_progress_status&.created_at || ticket.created_at
    
    activity_logs << ActivityLog.create!(
      user: admin,
      repair_ticket: ticket,
      action_type: 'ticket_assigned',
      description: "Ticket assigned to #{ticket.assigned_technician.full_name}",
      metadata: {
        technician_id: ticket.assigned_technician.id,
        technician_name: ticket.assigned_technician.full_name
      },
      created_at: timestamp,
      updated_at: timestamp
    )
  end
  
  # Log payments
  payments.each do |payment|
    activity_logs << ActivityLog.create!(
      user: payment.received_by,
      repair_ticket: payment.repair_ticket,
      action_type: 'payment_received',
      description: "Payment of R#{payment.amount} received via #{payment.payment_method.humanize}",
      metadata: {
        amount: payment.amount,
        payment_method: payment.payment_method,
        reference_number: payment.reference_number
      },
      created_at: payment.created_at,
      updated_at: payment.created_at
    )
  end
  
  # Add some random notes
  tickets.sample(20).each do |ticket|
    note_time = ticket.created_at + rand(1..5).days
    activity_logs << ActivityLog.create!(
      user: [admin, technician].sample,
      repair_ticket: ticket,
      action_type: 'note_added',
      description: [
        "Customer called for update",
        "Sent SMS notification to customer",
        "Customer confirmed pickup time",
        "Additional diagnostic completed",
        "Parts ordered from supplier",
        "Customer approved quote"
      ].sample,
      created_at: note_time,
      updated_at: note_time
    )
  end
  
  puts "(#{activity_logs.count} created)"
  end

  puts "\n🎉 Database seeded successfully!\n\n"
rescue StandardError => e
  puts "\n❌ Error seeding database: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  raise
end

# ==========================================
# SUMMARY
# ==========================================
puts "📊 Summary:"
puts "- Users: #{User.count} (#{User.admin.count} admin, #{User.technician.count} technician, #{User.cashier.count} cashier)"
puts "- Customers: #{Customer.count} (#{Customer.active.count} active, #{Customer.where(active: false).count} inactive)"
puts "- Devices: #{Device.count}"
puts "  - Phones: #{Device.phone.count}"
puts "  - Tablets: #{Device.tablet.count}"
puts "  - Laptops: #{Device.laptop.count}"
puts "  - Desktops: #{Device.desktop.count}"
puts "  - Other: #{Device.other.count}"
puts "- Repair Tickets: #{RepairTicket.count}"
puts "  - Pending: #{RepairTicket.pending.count}"
puts "  - In Progress: #{RepairTicket.in_progress.count}"
puts "  - Waiting for Parts: #{RepairTicket.waiting_for_parts.count}"
puts "  - Completed: #{RepairTicket.completed.count}"
puts "  - Collected: #{RepairTicket.collected.count}"
puts "  - Cancelled: #{RepairTicket.where(status: :cancelled).count}"
puts "- Repair Statuses: #{RepairStatus.count}"
puts "- Payments: #{Payment.count}"
puts "  - Total Amount: R#{Payment.sum(:amount)}"
puts "  - Cash: #{Payment.cash.count}"
puts "  - Card: #{Payment.card.count}"
puts "  - Bank Transfer: #{Payment.bank_transfer.count}"
puts "  - Other: #{Payment.other.count}"
puts "- Activity Logs: #{ActivityLog.count}"
puts "\n✨ Ready to use!"
