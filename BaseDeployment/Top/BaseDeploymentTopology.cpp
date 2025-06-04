// ======================================================================
// \title  BaseDeploymentTopology.cpp
// \brief cpp file containing the topology instantiation code
//
// ======================================================================
// Provides access to autocoded functions
#include <BaseDeployment/Top/BaseDeploymentTopologyAc.hpp>
#include <config/FppConstantsAc.hpp>

// Necessary project-specified types
#include <Fw/Types/MallocAllocator.hpp>
#include <Svc/FrameAccumulator/FrameDetector/FprimeFrameDetector.hpp>
#include <BaseDeployment/Top/Ports_ComPacketQueueEnumAc.hpp>

// Allows easy reference to objects in FPP/autocoder required namespaces
using namespace BaseDeployment;

// The reference topology uses a malloc-based allocator for components that need to allocate memory during the
// initialization phase.
Fw::MallocAllocator mallocator;

// FprimeFrameDetector is used to configure the FrameAccumulator to detect F Prime frames
Svc::FrameDetectors::FprimeFrameDetector frameDetector;

Svc::ComQueue::QueueConfigurationTable configurationTable;

// The reference topology divides the incoming clock signal (1kHz) into sub-signals: 10Hz, 1Hz
Svc::RateGroupDriver::DividerSet rateGroupDivisors = {{ {100, 0}, {1000, 0} }};

// Rate groups may supply a context token to each of the attached children whose purpose is set by the project. The
// reference topology sets each token to zero as these contexts are unused in this project.
U32 rateGroup1Context[FppConstant_PassiveRateGroupOutputPorts::PassiveRateGroupOutputPorts] = {};

/**
 * \brief configure/setup components in project-specific way
 *
 * This is a *helper* function which configures/sets up each component requiring project specific input. This includes
 * allocating resources, passing-in arguments, etc. This function may be inlined into the topology setup function if
 * desired, but is extracted here for clarity.
 */
void configureTopology() {

    // Frame accumulator needs to be passed a frame detector (default F Prime frame detector)
    frameAccumulator.configure(frameDetector, 1, mallocator, 2048);

    // Rate group driver needs a divisor list
    rateGroupDriver.configure(rateGroupDivisors);

    // Rate groups require context arrays.
    rateGroup1.configure(rateGroup1Context, FW_NUM_ARRAY_ELEMENTS(rateGroup1Context));

    // ComQueue configuration
    // Events (highest-priority)
    configurationTable.entries[Ports_ComPacketQueue::EVENTS].depth = 100;
    configurationTable.entries[Ports_ComPacketQueue::EVENTS].priority = 0;
    // Telemetry
    configurationTable.entries[Ports_ComPacketQueue::TELEMETRY].depth = 500;
    configurationTable.entries[Ports_ComPacketQueue::TELEMETRY].priority = 2;
    // File Downlink (first entry after the ComPacket queues = NUM_CONSTANTS)
    configurationTable.entries[Ports_ComPacketQueue::NUM_CONSTANTS].depth = 100;
    configurationTable.entries[Ports_ComPacketQueue::NUM_CONSTANTS].priority = 1;
    // Allocation identifier is 0 as the MallocAllocator discards it
    comQueue.configure(configurationTable, 0, mallocator);
}

// Public functions for use in main program are namespaced with deployment name BaseDeployment
namespace BaseDeployment {
void setupTopology(const TopologyState& state) {
    // Autocoded initialization. Function provided by autocoder.
    initComponents(state);
    // Autocoded id setup. Function provided by autocoder.
    setBaseIds();
    // Autocoded connection wiring. Function provided by autocoder.
    connectComponents();
    // Autocoded command registration. Function provided by autocoder.
    regCommands();
    // Project-specific component configuration. Function provided above. May be inlined, if desired.
    configureTopology();
    // Autocoded parameter loading. Function provided by autocoder.
    // loadParameters();
    // Autocoded task kick-off (active components). Function provided by autocoder.
    startTasks(state);

    rateDriver.configure(1);
    comDriver.configure(&Serial);
    gpioDriver.open(Arduino::DEF_LED_BUILTIN, Arduino::GpioDriver::GpioDirection::OUT);
    rateDriver.start();
}

void teardownTopology(const TopologyState& state) {
    // Autocoded (active component) task clean-up. Functions provided by topology autocoder.
    stopTasks(state);
    freeThreads(state);

}
};  // namespace BaseDeployment
