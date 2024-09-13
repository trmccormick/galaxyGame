# app/services/terra_sim1_1.rb

class TerraSim1_1
    def initialize
      @pole = 0
      @regolith = 0
      @pr = 0
      @tot_co2 = 0
      @td = 30
      @s = 0
      @a = 0
      @p_co2 = 0
      @p_n2 = 0
      @p_ch4 = 0
      @p_nh3 = 0
      @p_cfc = 0
      @p_h2o = 0
      @p_kr = 0
      @p_o2 = 0
      @p_ar = 0
      @tb = 0
      @ts = 0
      @tp = 0
      @tt = 0
      @c = 0
      @d_t = 0
      @ice_lat = 0
      @hab_ratio = 0
      @sm = 0
    end
  
    def set_info
      @celestial_body = Game.current_celestial_body
      @sun = Game.current_sun
    end
  
    def calc_current
      set_info
      puts "calcCurrent #{@celestial_body.name}"
  
      @a = @celestial_body.albedo.to_f
      @s = @celestial_body.insolation.to_f
  
      gas = @celestial_body.gas('CO2')
      if gas
        @p_co2 = gas.mb
        @pole = gas.pole
        @regolith = gas.regolith
        @pr = gas.pr
        @td = gas.td
      end
  
      gas = @celestial_body.gas('N')
      @p_n2 = gas ? gas.mb : 0
  
      gas = @celestial_body.gas('O2')
      @p_o2 = gas ? gas.mb : 0
  
      gas = @celestial_body.gas('Ar')
      @p_ar = gas ? gas.mb : 0
  
      gas = @celestial_body.gas('Kr')
      @p_kr = gas ? gas.mb : 0
  
      gas = @celestial_body.gas('CH4')
      @p_ch4 = gas ? gas.mb : 0
  
      gas = @celestial_body.gas('NH3')
      @p_nh3 = gas ? gas.mb : 0
  
      gas = @celestial_body.gas('CFC')
      @p_cfc = gas ? gas.mb : 0
  
      gas = @celestial_body.gas('H2O')
      @p_h2o = gas ? gas.mb : 0
  
      @sm = @celestial_body.solar_constant(@sun).to_f
  
      @pole /= 1E3
      @pr /= 1E3
      @regolith /= 1E3
      @p_co2 /= 1E3
      @p_n2 /= 1E3
      @p_n2 += (@p_o2 / 1E3)
      @p_n2 += (@p_ar / 1E3)
      @p_n2 += (@p_kr / 1E3)
      @p_ch4 /= 1E6
      @p_nh3 /= 1E6
      @p_cfc /= 10
      @c = @regolith * (0.006**(-0.275)) * Math.exp(149 / @td)
      @tot_co2 = @pr + @pole + @p_co2
  
      greenhouse
      output
      @celestial_body
    end
  
    def greenhouse
      sigma = 0.0000000567
  
      t_h2o = 0
  
      @tb = ((1 - 0.2) * @sm / (4 * sigma))**0.25
      @ts = @tb
      @tp = @ts - 75
  
      100.times do
        t_h2o = (p_h2o**0.3)
  
        @ts = (((1 - @a) * @sm * @s) / (4 * sigma))**0.25 *
              ((1 + t_co2 + t_h2o + t_ch4 + t_nh3 + t_cfc)**0.25)
        @tp = @ts - (75 / (1 + 5 * p_tot))
  
        @p_co2 = p_co2
      end
  
      @tt = @ts * 1.1
      @d_t = @ts - @tb
  
      biosphere
    end
  
    def output
      @celestial_body.set_gas('CO2', @p_co2 * 1000, @pr * 1000, @regolith * 1000, @pole * 1000, @td)
      @celestial_body.set_gas('H2O', @p_h2o * 1000, 0, 0, 0, 0)
  
      @celestial_body.set_effective_temp(@tb.to_s)
      @celestial_body.set_greenhouse_temp(@ts.to_s)
      @celestial_body.set_polar_temp(@tp.to_s)
      @celestial_body.set_tropic_temp(@tt.to_s)
      @celestial_body.set_delta_t(@d_t.to_s)
      val = @ice_lat * 180 / Math::PI
      @celestial_body.set_ice_lat(val.to_s)
      @celestial_body.set_hab_ratio(@hab_ratio.to_s)
  
      @celestial_body
    end
  
    private
  
    def p_h2o
      rh = 0.7
      rgas = 8.314
      lheat = 43655.0
      p0 = 1.4E6
  
      rh * p0 * Math.exp(-lheat / (rgas * @ts))
    end
  
    def p_tot
      @p_co2 + @p_n2 + @p_ch4 + @p_nh3 + (@p_cfc / 1E5) + p_h2o
    end
  
    def t_co2
      0.9 * p_tot**0.45 * @p_co2**0.11
    end
  
    def t_ch4
      0.5 * @p_ch4**0.278
    end
  
    def t_nh3
      9.6 * @p_nh3**0.32
    end
  
    def t_cfc
      (1.1 * @p_cfc) / (0.015 + @p_cfc)
    end
  
    def p_co2
      pv = 1.23E7 * Math.exp(-3168 / @tp)
      pa = @p_co2
  
      if pv > pa && @pole > 0 && pv < pa + @pole
        @pole -= (pv - pa)
        pa = pv
      end
  
      if pv > pa + @pole && @pole > 0
        pa += @pole
        @pole = 0
      end
  
      if pv < pa
        @pole -= (pv - pa)
        pa = pv
      end
  
      x = pa + @pr
      x = @tot_co2 if x > @tot_co2
      y = @c * Math.exp(-@tp / @td)
      top = @tot_co2
      bottom = 0
      pa = 0.5 * @regolith
  
      50.times do
        if y * pa**0.275 + pa < x
          bottom = pa
        else
          top = pa
        end
        pa = bottom + (top - bottom) / 2
      end
  
      @pr = y * pa**0.275
      @pr = @regolith if @pr > @regolith
  
      pa
    end
  
    def biosphere
      if @tt > 273 && @tp < 273
        @hab_ratio = ((@tt - 273) / (@tt - @tp))**0.666667
        @ice_lat = Math.asin(@hab_ratio)
      elsif @tt < 273
        @hab_ratio = 0
        @ice_lat = 0
      elsif @tp > 273
        @hab_ratio = 1
        @ice_lat = Math.asin(1)
      end
    end
end  
  