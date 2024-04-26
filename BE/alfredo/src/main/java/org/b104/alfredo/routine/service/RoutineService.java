package org.b104.alfredo.routine.service;

import org.b104.alfredo.routine.domain.Routine;

import java.time.LocalTime;
import java.util.List;
import java.util.Set;

public interface RoutineService {

    List<Routine> getAllRoutines(String uid);
    Routine getRoutine(Long id);

    Routine createRoutine(String routineTitle, LocalTime startTime, Set<String> days, String alarmSound, String memo, String uId);

    void deleteRoutine(Long routineId);

    Routine updateRoutine(Long routineId,String routineTitle, LocalTime startTime, Set<String> days, String alarmSound, String memo);
}