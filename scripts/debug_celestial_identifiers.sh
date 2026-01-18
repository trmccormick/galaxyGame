#!/bin/bash
# Debug what celestial body identifiers actually exist

echo "🔍 DEBUGGING CELESTIAL BODY IDENTIFIERS"
echo "========================================"
echo ""

echo "Step 1: List All Celestial Bodies in Test DB"
echo "---------------------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  puts 'All Celestial Bodies in test database:'
  puts ''
  CelestialBodies::CelestialBody.all.each do |body|
    puts '  Name: ' + body.name.to_s.ljust(20) + ' | Identifier: ' + (body.identifier || 'NULL').inspect
  end
\"
"

echo ""
echo "Step 2: Check Seeds File"
echo "------------------------"
docker exec -it web bash -c "
echo 'Checking what identifiers are in the seeds file:'
grep -n 'identifier:' db/seeds.rb | head -20
"

echo ""
echo "Step 3: Try Case-Insensitive Search"
echo "------------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  puts 'Searching for Sol/Mars/Earth (case-insensitive):'
  
  ['sol', 'Sol', 'SOL', 'sun', 'Sun'].each do |term|
    result = CelestialBodies::CelestialBody.where('LOWER(identifier) = ? OR LOWER(name) = ?', term.downcase, term.downcase).first
    puts '  ' + term.ljust(10) + ': ' + (result ? '✅ Found as ' + result.name : '❌ Not found')
  end
  
  puts ''
  ['mars', 'Mars', 'MARS'].each do |term|
    result = CelestialBodies::CelestialBody.where('LOWER(identifier) = ? OR LOWER(name) = ?', term.downcase, term.downcase).first
    puts '  ' + term.ljust(10) + ': ' + (result ? '✅ Found as ' + result.name : '❌ Not found')
  end
  
  puts ''
  ['earth', 'Earth', 'EARTH'].each do |term|
    result = CelestialBodies::CelestialBody.where('LOWER(identifier) = ? OR LOWER(name) = ?', term.downcase, term.downcase).first
    puts '  ' + term.ljust(10) + ': ' + (result ? '✅ Found as ' + result.name : '❌ Not found')
  end
\"
"

echo ""
echo "Step 4: Check Schema for Identifier Column"
echo "-------------------------------------------"
docker exec -it web bash -c "
unset DATABASE_URL
RAILS_ENV=test rails runner \"
  schema = ActiveRecord::Base.connection.columns(:celestial_bodies)
  puts 'Columns in celestial_bodies table:'
  schema.each do |col|
    puts '  - ' + col.name + ' (' + col.type.to_s + ')'
  end
  
  puts ''
  puts 'Does identifier column exist? ' + (schema.any? { |c| c.name == 'identifier' } ? '✅ YES' : '❌ NO')
\"
"

echo ""
echo "📋 ANALYSIS"
echo "==========="
echo "This will show us:"
echo "1. What identifiers actually exist in the database"
echo "2. What the seeds file is trying to create"
echo "3. Whether it's a case sensitivity issue"
echo "4. Whether the identifier column even exists"
echo ""
echo "Share the output and we'll fix the identifier mismatch!"