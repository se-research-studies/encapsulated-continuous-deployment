#!/bin/bash

cat <<EOF > MainModule.cpp
/**
 * OpenDaVINCI - Portable middleware for distributed components.
 * Copyright (C) 2008 - 2016 Christian Berger
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
#include "Example1.h"
int32_t main(int32_t argc, char **argv) {
    examples::Example1 e1(argc, argv);
    return e1.runModule();
}
EOF

cat <<EOF > Example1.cpp
/**
 * OpenDaVINCI - Portable middleware for distributed components.
 * Copyright (C) 2008 - 2016 Christian Berger 
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
#include <iostream>
#include "Example1.h"
namespace examples {
    using namespace std;
    using namespace core::base::module;
    Example1::Example1(const int32_t &argc, char **argv) :
            TimeTriggeredConferenceClientModule(argc, argv, "Example1")
    		{}
    Example1::~Example1() {}
    void Example1::setUp() {}
    void Example1::tearDown() {}
    coredata::dmcp::ModuleExitCodeMessage::ModuleExitCode Example1::body() {
        cout << "Hello OpenDaVINCI World!" << endl;
        return coredata::dmcp::ModuleExitCodeMessage::OKAY;
    }
} // examples
EOF

cat <<EOF > Example1.h
/**
 * OpenDaVINCI - Portable middleware for distributed components.
 * Copyright (C) 2008 - 2016 Christian Berger 
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
#ifndef EXAMPLE1_H_
#define EXAMPLE1_H_
#include "core/base/module/TimeTriggeredConferenceClientModule.h"
namespace examples {
    using namespace std;
    /**
     * This class is a "Hello World" with OpenDaVINCI.
     */
    class Example1 : public core::base::module::TimeTriggeredConferenceClientModule {
        private:
            /**
             * "Forbidden" copy constructor. Goal: The compiler should warn
             * already at compile time for unwanted bugs caused by any misuse
             * of the copy constructor.
             *
             * @param obj Reference to an object of this class.
             */
            Example1(const Example1 &/*obj*/);
            /**
             * "Forbidden" assignment operator. Goal: The compiler should warn
             * already at compile time for unwanted bugs caused by any misuse
             * of the assignment operator.
             *
             * @param obj Reference to an object of this class.
             * @return Reference to this instance.
             */
            Example1& operator=(const Example1 &/*obj*/);
        public:
            /**
             * Constructor.
             *
             * @param argc Number of command line arguments.
             * @param argv Command line arguments.
             */
            Example1(const int32_t &argc, char **argv);
            virtual ~Example1();
            coredata::dmcp::ModuleExitCodeMessage::ModuleExitCode body();
        private:
            virtual void setUp();
            virtual void tearDown();
    };
} // examples
#endif /*EXAMPLE1_H_*/
EOF

touch configuration
echo "Start odsupercomponent."
odsupercomponent --cid=111 &

sleep 2 
echo "Compiling test program." && \
    g++ -c Example1.cpp -o Example1.o -I/usr/include/opendavinci && \
    g++ -c MainModule.cpp -o MainModule.o -I/usr/include/opendavinci && \
    g++ -o MainModule MainModule.o Example1.o -lopendavinci -lpthread -lrt && \
    echo "Test program successfully compiled, running it..." && \
    ./MainModule --cid=111 --verbose=1 && \
    echo "Test program successfully executed, quitting..." && \
    killall --signal=SIGINT odsupercomponent && \
    echo "Test successfully completed."
