/*****************************************************************************************************
 *            laser.cpp
 *
 *  Testing the laser cutting system.
 *
 *  Copyright  2016  Luca Geretti
 *
 *****************************************************************************************************/

/*
 *  This file is part of Ariadne.
 *
 *  Ariadne is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Ariadne is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Ariadne.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "ariadne.hpp"
#include "drawing/drawing_command_line_interface.hpp"

#include "laser/skin-exposure.hpp"
#include "laser/laser-trajectory.hpp"
#include "laser/cutting-depth.hpp"
#include "laser/skin-temperature.hpp"

using namespace Ariadne;

int main(int argc, const char* argv[])
{
    if (not DrawingCommandLineInterface().acquire(argc, argv)) return -1;

    /// Build the Hybrid System

    /// Get the automata
    HybridAutomaton laser_trajectory = getLaserTrajectory();
    HybridAutomaton exposure = getSkinExposure();
    HybridAutomaton skin_temperature = getSkinTemperature();
    HybridAutomaton cutting_depth = getCuttingDepth();

    //CompositeHybridAutomaton laser_system({laser_trajectory,exposure,skin_temperature,cutting_depth});
    CompositeHybridAutomaton laser_system({laser_trajectory,exposure});
    std::cout << "laser_system:\n" << laser_system << "\n";

    // Compute the system evolution

    // Create a GeneralHybridEvolver object
    GeneralHybridEvolver evolver(laser_system);

    // Set the evolution parameters
    evolver.configuration().set_maximum_enclosure_radius(0.5);
    evolver.configuration().set_maximum_step_size(0.0001);
    std::cout << evolver.configuration() << std::endl;

    // Declare the type to be used for the system evolution
    typedef GeneralHybridEvolver::OrbitType OrbitType;

    StringVariable trajectory_mode("trajectory"), exposure_mode("skin-exposure");
    DiscreteLocation initial_location={trajectory_mode|"scanning",exposure_mode|"far"};
    RealVariable p("p"), z("z"), zi("zi"), T("T"), vx("vx"), x("x");
    //HybridSet initial_set(initial_location,{p==0,z==0,zi==0,T==37,vx==Real(-0.092_dec),x==Real(0.0033_dec)});
    HybridSet initial_set(initial_location,{p==0,vx==Real(-0.092_dec),x==Real(0.0033_dec)});

    HybridTime evolution_time(0.5_dec,2);

    std::cout << "Computing orbit... " << std::flush;

    OrbitType orbit = evolver.orbit(initial_set,evolution_time,Semantics::UPPER);
    std::cout << "done." << std::endl;

}
