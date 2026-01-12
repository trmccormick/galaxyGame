# lib/tasks/solar_system_progression.rake
require 'json'
require 'securerandom'

namespace :missions do
  namespace :solar_system do
    desc "Execute simplified solar system progression with observable GCC flows"
    task simple_progression: :environment do
      puts "\n🚀 === SOLAR SYSTEM ECONOMIC PROGRESSION ==="
      puts "Simplified deployment showing GCC flows and material transfers\n"

      progression = SimpleSolarProgression.new
      progression.execute_progression
    end
  end
end

class SimpleSolarProgression
  def initialize
    @corporations = {}
    @total_transfers = 0
  end

  def execute_progression
    puts "Setting up basic economic infrastructure..."

    # Create GCC currency
    gcc = Financial::Currency.find_or_create_by!(symbol: 'GCC') do |c|
      c.name = 'Galactic Crypto Currency'
      c.is_system_currency = true
      c.precision = 8
    end
    puts "✓ GCC currency established"

    # PHASE 1: Lunar Development Corporation
    puts "\n🌙 PHASE 1: LUNAR DEVELOPMENT CORPORATION"
    create_lunar_corp
    show_gcc_status("Lunar Corp Created")

    # PHASE 2: Venus Atmospheric Corporation
    puts "\n🌑 PHASE 2: VENUS ATMOSPHERIC CORPORATION"
    create_venus_corp
    show_gcc_status("Venus Corp Created")

    # PHASE 3: Mars Industrial Corporation
    puts "\n🔴 PHASE 3: MARS INDUSTRIAL CORPORATION"
    create_mars_corp
    show_gcc_status("Mars Corp Created")

    # PHASE 4: Material Transfers
    puts "\n💰 PHASE 4: INTERPLANETARY MATERIAL TRANSFERS"
    execute_material_transfers

    # Final Status
    puts "\n📊 FINAL ECONOMIC STATUS"
    display_final_status
  end

  private

  def create_lunar_corp
    # Create LDC corporation
    ldc_org = Organizations::BaseOrganization.find_or_create_by!(identifier: 'LDC') do |o|
      o.name = "Lunar Development Corporation"
      o.organization_type = 'corporation'
      o.description = "Lunar resource extraction and GCC banking"
    end

    # Create LDC account
    ldc_account = Financial::Account.find_or_create_by!(
      accountable: ldc_org,
      currency: Financial::Currency.find_by(symbol: 'GCC')
    ) do |a|
      a.balance = 10_000_000.0
    end

    @corporations[:ldc] = { organization: ldc_org, account: ldc_account }
    puts "✓ LDC established with 10,000,000 GCC"
  end

  def create_venus_corp
    # Create Venus corporation
    venus_org = Organizations::BaseOrganization.find_or_create_by!(identifier: 'VENUS_CORP') do |o|
      o.name = "Venus Atmospheric Corporation"
      o.organization_type = 'corporation'
      o.description = "Venus atmospheric gas harvesting"
    end

    # Create Venus account
    venus_account = Financial::Account.find_or_create_by!(
      accountable: venus_org,
      currency: Financial::Currency.find_by(symbol: 'GCC')
    ) do |a|
      a.balance = 3_000_000.0
    end

    @corporations[:venus] = { organization: venus_org, account: venus_account }
    puts "✓ Venus Corp established with 3,000,000 GCC"
  end

  def create_mars_corp
    # Create Mars corporation
    mars_org = Organizations::BaseOrganization.find_or_create_by!(identifier: 'MARS_CORP') do |o|
      o.name = "Mars Industrial Corporation"
      o.organization_type = 'corporation'
      o.description = "Mars industrial manufacturing"
    end

    # Create Mars account
    mars_account = Financial::Account.find_or_create_by!(
      accountable: mars_org,
      currency: Financial::Currency.find_by(symbol: 'GCC')
    ) do |a|
      a.balance = 4_000_000.0
    end

    @corporations[:mars] = { organization: mars_org, account: mars_account }
    puts "✓ Mars Corp established with 4,000,000 GCC"
  end

  def execute_material_transfers
    # Venus buys lunar materials from LDC
    material_cost = 500_000.0
    transfer_funds(@corporations[:venus][:account], @corporations[:ldc][:account],
                  material_cost, "Venus purchases lunar construction materials")
    puts "💰 Venus → LDC: #{material_cost} GCC (lunar materials)"

    # Mars buys atmospheric gases from Venus
    gas_cost = 200_000.0
    transfer_funds(@corporations[:mars][:account], @corporations[:venus][:account],
                  gas_cost, "Mars purchases atmospheric gases")
    puts "💨 Mars → Venus: #{gas_cost} GCC (CO2/N2 gases)"

    # Mars pays LDC for banking services
    banking_fee = 50_000.0
    transfer_funds(@corporations[:mars][:account], @corporations[:ldc][:account],
                  banking_fee, "Mars pays LDC banking fees")
    puts "🏛️ Mars → LDC: #{banking_fee} GCC (banking services)"
  end

  def transfer_funds(from_account, to_account, amount, description)
    from_account.update!(balance: from_account.balance - amount)
    to_account.update!(balance: to_account.balance + amount)
    @total_transfers += 1

    # Create transactions
    from_account.transactions.create!(
      amount: -amount,
      description: description,
      transaction_type: :transfer,
      recipient: to_account.accountable,
      currency: from_account.currency
    )

    to_account.transactions.create!(
      amount: amount,
      description: description,
      transaction_type: :transfer,
      recipient: from_account.accountable,
      currency: to_account.currency
    )
  end

  def show_gcc_status(phase)
    puts "\n💰 GCC STATUS AFTER #{phase.upcase}:"
    @corporations.each do |name, corp|
      balance = corp[:account].balance.round(2)
      puts "  #{name.to_s.upcase}: #{balance} GCC"
    end
  end

  def display_final_status
    puts "\n🏛️ CORPORATIONS:"
    @corporations.each do |name, corp|
      balance = corp[:account].balance.round(2)
      puts "  #{corp[:organization].name}: #{balance} GCC"
    end

    total_gcc = @corporations.values.sum { |corp| corp[:account].balance }
    puts "\n💎 TOTAL SYSTEM GCC: #{total_gcc}"
    puts "🔄 TOTAL TRANSACTIONS: #{@total_transfers}"

    most_valuable = @corporations.max_by { |_, corp| corp[:account].balance }
    puts "🏆 MOST VALUABLE: #{most_valuable[1][:organization].name}"

    puts "\n✅ Basic interplanetary economy operational!"
  end
end