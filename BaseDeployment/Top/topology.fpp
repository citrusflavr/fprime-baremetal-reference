module BaseDeployment {

  # ----------------------------------------------------------------------
  # Symbolic constants for port numbers
  # ----------------------------------------------------------------------

    enum Ports_RateGroups {
      rateGroup1
    }

    enum Ports_ComPacketQueue {
      EVENTS,
      TELEMETRY
    }

    enum Ports_StaticMemory {
      framer
      comDriver
      accumulator
      router
    }

  topology BaseDeployment {

    # ----------------------------------------------------------------------
    # Instances used in the topology
    # ----------------------------------------------------------------------

    instance blinker
    instance cmdDisp
    instance comDriver
    instance comQueue
    instance comStub
    instance fprimeRouter
    instance deframer
    instance frameAccumulator
    instance eventLogger
    instance fatalAdapter
    instance fatalHandler
    instance framer
    instance gpioDriver
    instance rateDriver
    instance rateGroup1
    instance rateGroupDriver
    instance staticMemory
    instance systemResources
    instance systemTime
    instance textLogger
    instance tlmSend

    # ----------------------------------------------------------------------
    # Pattern graph specifiers
    # ----------------------------------------------------------------------

    command connections instance cmdDisp

    event connections instance eventLogger

    telemetry connections instance tlmSend

    text event connections instance textLogger

    time connections instance systemTime

    # ----------------------------------------------------------------------
    # Direct graph specifiers
    # ----------------------------------------------------------------------

    connections RateGroups {
      # Block driver
      rateDriver.CycleOut -> rateGroupDriver.CycleIn

      # Rate group 1
      rateGroupDriver.CycleOut[Ports_RateGroups.rateGroup1] -> rateGroup1.CycleIn
      rateGroup1.RateGroupMemberOut[0] -> blinker.run
      rateGroup1.RateGroupMemberOut[1] -> comDriver.schedIn
      rateGroup1.RateGroupMemberOut[2] -> tlmSend.Run
      rateGroup1.RateGroupMemberOut[3] -> systemResources.run
      rateGroup1.RateGroupMemberOut[4] -> comQueue.run
    }

    connections FaultProtection {
      eventLogger.FatalAnnounce -> fatalHandler.FatalReceive
    }

    connections Downlink {

      #tlmSend.PktSend -> framer.comIn
      #eventLogger.PktSend -> framer.comIn
      # Inputs to ComQueue (events, telemetry)
      eventLogger.PktSend         -> comQueue.comPacketQueueIn[Ports_ComPacketQueue.EVENTS]
      tlmSend.PktSend             -> comQueue.comPacketQueueIn[Ports_ComPacketQueue.TELEMETRY]

      # ComQueue <-> Framer
      comQueue.dataOut   -> framer.dataIn
      framer.dataReturnOut -> comQueue.dataReturnIn
      framer.comStatusOut  -> comQueue.comStatusIn

      # Static Memory for Framer
      framer.bufferAllocate -> staticMemory.bufferAllocate[Ports_StaticMemory.framer]
      framer.bufferDeallocate -> staticMemory.bufferDeallocate[Ports_StaticMemory.framer]

      # Framer <-> ComStub
      framer.dataOut        -> comStub.dataIn
      comStub.dataReturnOut -> framer.dataReturnIn
      comStub.comStatusOut  -> framer.comStatusIn

      # ComStub <-> ComDriver
      comStub.drvSendOut      -> comDriver.$send
      comDriver.sendReturnOut -> comStub.drvSendReturnIn
      comDriver.ready         -> comStub.drvConnected
    }

    connections Uplink {
      # ComDriver buffer allocations
      comDriver.allocate      -> staticMemory.bufferAllocate[Ports_StaticMemory.comDriver]
      comDriver.deallocate    -> staticMemory.bufferDeallocate[Ports_StaticMemory.comDriver]

      # ComDriver <-> ComStub
      comDriver.$recv             -> comStub.drvReceiveIn
      comStub.drvReceiveReturnOut -> comDriver.recvReturnIn

      # ComStub <-> FrameAccumulator
      comStub.dataOut                -> frameAccumulator.dataIn
      frameAccumulator.dataReturnOut -> comStub.dataReturnIn

      # FrameAccumulator buffer allocations
      frameAccumulator.bufferDeallocate -> staticMemory.bufferDeallocate[Ports_StaticMemory.accumulator]
      frameAccumulator.bufferAllocate   -> staticMemory.bufferAllocate[Ports_StaticMemory.accumulator]

      # FrameAccumulator <-> Deframer
      frameAccumulator.dataOut  -> deframer.dataIn
      deframer.dataReturnOut    -> frameAccumulator.dataReturnIn

      # Deframer <-> Router
      deframer.dataOut           -> fprimeRouter.dataIn
      fprimeRouter.dataReturnOut -> deframer.dataReturnIn

      # Router buffer allocations
      fprimeRouter.bufferAllocate   -> staticMemory.bufferAllocate[Ports_StaticMemory.router]
      fprimeRouter.bufferDeallocate -> staticMemory.bufferDeallocate[Ports_StaticMemory.router]

      # Router <-> CmdDispatcher
      fprimeRouter.commandOut  -> cmdDisp.seqCmdBuff
      cmdDisp.seqCmdStatus     -> fprimeRouter.cmdResponseIn

    }

    connections BaseDeployment {
      # Add here connections to user-defined components
      blinker.gpioSet -> gpioDriver.gpioWrite
    }

  }

}
