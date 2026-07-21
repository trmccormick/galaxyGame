require 'rails_helper'

RSpec.describe 'Admin Monitor Canvas', type: :feature do
  
  # Helper method to extract JSON from monitor-data script tag
  def get_monitor_data_json(page)
    match = page.body.match(/<script[^>]*id="monitor-data"[^>]*>(.*?)<\/script>/m)
    return nil unless match
    
    begin
      JSON.parse(match.captures.first.strip)
    rescue JSON::ParserError
      nil
    end
  end
  
  describe 'planetary view - canvas rendering on page load' do
    
    context 'with complete celestial body data (terrain map present)' do
      
      let!(:celestial_body) { create(:celestial_body, :minimal, name: 'Test Planet') }
      
      before do
        # Ensure geosphere has terrain_map for this test
        celestial_body.geosphere.update!(
          terrain_map: {
            elevation: [1.0, 2.0, 3.0],
            biomes: ['grasslands', 'desert', 'forest'],
            quality: 'high'
          }
        )
      end
      
      it 'renders canvas element with monitor data' do
        visit planetary_admin_celestial_body_path(celestial_body)
        
        expect(page).to have_css('#planetCanvas')
        # Check that the script tag exists in DOM (it's not visible but should be present)
        expect(page.body).to include('id="monitor-data"')
      end
      
      it 'injects correct planet data into monitor-data element' do
        visit planetary_admin_celestial_body_path(celestial_body)
        
        # Extract JSON from script tag in DOM
        json_data = get_monitor_data_json(page)
        expect(json_data).to be_a Hash
        
        expect(json_data['planet_name']).to eq('Test Planet')
        expect(json_data['terrain_map_present']).to be true
        expect(json_data['available_layers']['terrain']).to be true
        
        # Verify geosphere is present in the injected data
        expect(json_data).to have_key('geosphere_present')
      end
      
      it 'includes available layers based on planetary conditions' do
        visit planetary_admin_celestial_body_path(celestial_body)
        
        json_data = get_monitor_data_json(page)
        expect(json_data).to be_a Hash
        
        # terrain layer should always be available if we have terrain_map
        expect(json_data['available_layers']['terrain']).to be true
        
        # water/biomes depend on presence of hydrosphere/biosphere - check in available_layers structure
        expect(json_data['available_layers']).to have_key('water')
      end
      
    end
    
    context 'with missing terrain data' do
      
      let!(:celestial_body) { create(:celestial_body, :minimal, name: 'EmptyWorld') }
      
      before do
        # Ensure geosphere exists but has no terrain_map (nil)
        celestial_body.geosphere.update!(terrain_map: nil)
      end
      
      it 'handles missing terrain data gracefully' do
        visit planetary_admin_celestial_body_path(celestial_body)
        
        expect(page).to have_css('#planetCanvas')
        # Check that the script tag exists in DOM (it's not visible but should be present)
        expect(page.body).to include('id="monitor-data"')
        
        json_data = get_monitor_data_json(page)
        expect(json_data).to be_a Hash
        
        # Verify terrain_map_present is false but page still renders
        expect(json_data['terrain_map_present']).to be false
        expect(json_data['geosphere_present']).to be true
        
        # Should not show error messages - graceful degradation
        expect(page).not_to have_content('Error')
      end
      
    end
    
    context 'with minimal celestial body (no geosphere)' do
      
      let!(:celestial_body) { create(:celestial_body, :without_spheres, name: 'NoGeosphere') }
      
      it 'still renders canvas without errors' do
        visit planetary_admin_celestial_body_path(celestial_body)
        
        expect(page).to have_css('#planetCanvas')
        # Check that the script tag exists in DOM (it's not visible but should be present)
        expect(page.body).to include('id="monitor-data"')
      end
      
      it 'indicates geosphere is present (trait creates minimal spheres)' do
        visit planetary_admin_celestial_body_path(celestial_body)
        
        json_data = get_monitor_data_json(page)
        expect(json_data).to be_a Hash
        
        # :without_spheres trait still allows after(:create) callbacks to create geosphere
        # so it should be present, just without terrain_map
        expect(json_data['geosphere_present']).to be true
      end
      
    end
    
    context 'with complete celestial body (all spheres present)' do
      
      let!(:celestial_body) { create(:celestial_body, :minimal, name: 'CompleteWorld') }
      
      before do
        # Ensure all spheres are created for this test
        celestial_body.create_atmosphere unless celestial_body.atmosphere
        celestial_body.create_hydrosphere unless celestial_body.hydrosphere  
        celestial_body.create_biosphere unless celestial_body.biosphere
        celestial_body.geosphere.update!(terrain_map: {'elevation' => [[1.0]]})
      end
      
      it 'renders complete planetary data with all spheres' do
        visit planetary_admin_celestial_body_path(celestial_body)
        
        json_data = get_monitor_data_json(page)
        expect(json_data).to be_a Hash
        
        expect(json_data['planet_name']).to eq('CompleteWorld')
        expect(json_data['geosphere_present']).to be true
      end
      
    end
    
  end
  
  describe 'planetary vs surface views' do
    
    context 'with complete celestial body data' do
      
      let!(:celestial_body) { create(:celestial_body, :minimal, name: 'ViewComparison') }
      
      before do
        # Ensure geosphere has terrain_map for this test
        celestial_body.geosphere.update!(terrain_map: {'elevation' => [[1.0]]})
      end
      
      it 'renders planetary view correctly' do
        visit planetary_admin_celestial_body_path(celestial_body)
        
        expect(page).to have_css('#planetCanvas')
        json_data = get_monitor_data_json(page)
        expect(json_data['planet_name']).to eq('ViewComparison')
      end
      
      it 'renders surface view correctly' do
        visit surface_admin_celestial_body_path(celestial_body)
        
        # Surface view may not use monitor.js - check for expected content instead
        expect(page).to have_content('ViewComparison')
      end
      
    end
    
  end
  
end
