// Written in the D programming language

/++
    $(SCRIPT inhibitQuickIndex = 1;)

    Phobos provides the following functionality for time:

    $(DIVC quickindex,
    $(BOOKTABLE ,
    $(TR $(TH Functionality) $(TH Symbols)
    )
    $(TR
        $(TD Points in Time)
        $(TD
            $(REF_ALTTEXT Date, Date, std, datetime, date)$(NBSP)
            $(REF_ALTTEXT TimeOfDay, TimeOfDay, std, datetime, date)$(NBSP)
            $(REF_ALTTEXT DateTime, DateTime, std, datetime, date)$(NBSP)
            $(REF_ALTTEXT SysTime, SysTime, std, datetime, systime)$(NBSP)
        )
    )
    $(TR
        $(TD Timezones)
        $(TD
            $(REF_ALTTEXT TimeZone, TimeZone, std, datetime, timezone)$(NBSP)
            $(REF_ALTTEXT UTC, UTC, std, datetime, timezone)$(NBSP)
            $(REF_ALTTEXT LocalTime, LocalTime, std, datetime, timezone)$(NBSP)
            $(REF_ALTTEXT PosixTimeZone, PosixTimeZone, std, datetime, timezone)$(NBSP)
            $(REF_ALTTEXT WindowsTimeZone, WindowsTimeZone, std, datetime, timezone)$(NBSP)
            $(REF_ALTTEXT SimpleTimeZone, SimpleTimeZone, std, datetime, timezone)$(NBSP)
        )
    )
    $(TR
        $(TD Intervals and Ranges of Time)
        $(TD
            $(REF_ALTTEXT Interval, Interval, std, datetime, interval)$(NBSP)
            $(REF_ALTTEXT PosInfInterval, PosInfInterval, std, datetime, interval)$(NBSP)
            $(REF_ALTTEXT NegInfInterval, NegInfInterval, std, datetime, interval)$(NBSP)
        )
    )
    $(TR
        $(TD Durations of Time)
        $(TD
            $(REF_ALTTEXT Duration, Duration, core, time)$(NBSP)
            $(REF_ALTTEXT weeks, weeks, core, time)$(NBSP)
            $(REF_ALTTEXT days, days, core, time)$(NBSP)
            $(REF_ALTTEXT hours, hours, core, time)$(NBSP)
            $(REF_ALTTEXT minutes, minutes, core, time)$(NBSP)
            $(REF_ALTTEXT seconds, seconds, core, time)$(NBSP)
            $(REF_ALTTEXT msecs, msecs, core, time)$(NBSP)
            $(REF_ALTTEXT usecs, usecs, core, time)$(NBSP)
            $(REF_ALTTEXT hnsecs, hnsecs, core, time)$(NBSP)
            $(REF_ALTTEXT nsecs, nsecs, core, time)$(NBSP)
        )
    )
    $(TR
        $(TD Time Measurement and Benchmarking)
        $(TD
            $(REF_ALTTEXT MonoTime, MonoTime, core, time)$(NBSP)
            $(REF_ALTTEXT StopWatch, StopWatch, std, datetime, stopwatch)$(NBSP)
            $(REF_ALTTEXT benchmark, benchmark, std, datetime, stopwatch)$(NBSP)
        )
    )
    ))

    This functionality is separated into the following modules

    $(UL
        $(LI $(MREF std, datetime, date) for points in time without timezones.)
        $(LI $(MREF std, datetime, timezone) for classes which represent timezones.)
        $(LI $(MREF std, datetime, systime) for a point in time with a timezone.)
        $(LI $(MREF std, datetime, interval) for types which represent series of points in time.)
        $(LI $(MREF std, datetime, stopwatch) for measuring time.)
    )

    See_Also:
        $(DDLINK intro-to-datetime, Introduction to std.datetime,
                 Introduction to std&#46;datetime)<br>
        $(HTTP en.wikipedia.org/wiki/ISO_8601, ISO 8601)<br>
        $(HTTP en.wikipedia.org/wiki/Tz_database,
              Wikipedia entry on TZ Database)<br>
        $(HTTP en.wikipedia.org/wiki/List_of_tz_database_time_zones,
              List of Time Zones)<br>

    License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:   $(HTTP jmdavisprog.com, Jonathan M Davis) and Kato Shoichi
    Source:    $(PHOBOSSRC std/datetime/package.d)
+/
module std.datetime;

/// Get the current time from the system clock
@safe unittest
{
    import std.datetime.systime : SysTime, Clock;

    SysTime currentTime = Clock.currTime();
}

/**
Construct a specific point in time without timezone information
and get its ISO string.
 */
@safe unittest
{
    import std.datetime.date : DateTime;

    auto dt = DateTime(2018, 1, 1, 12, 30, 10);
    assert(dt.toISOString() == "20180101T123010");
    assert(dt.toISOExtString() == "2018-01-01T12:30:10");
}

/**
Construct a specific point in time in the UTC timezone and
add two days.
 */
@safe unittest
{
    import std.datetime.systime : SysTime;
    import std.datetime.timezone : UTC;
    import core.time : days;

    auto st = SysTime(DateTime(2018, 1, 1, 12, 30, 10), UTC());
    assert(st.toISOExtString() == "2018-01-01T12:30:10Z");
    st += 2.days;
    assert(st.toISOExtString() == "2018-01-03T12:30:10Z");
}

public import core.time;
public import std.datetime.date;
public import std.datetime.interval;
public import std.datetime.systime;
public import std.datetime.timezone;

import core.exception : AssertError;
import std.functional : unaryFun;
import std.traits;
import std.typecons : Flag, Yes, No;


// Verify module example.
@safe unittest
{
    auto currentTime = Clock.currTime();
    auto timeString = currentTime.toISOExtString();
    auto restoredTime = SysTime.fromISOExtString(timeString);
}

// Verify Examples for core.time.Duration which couldn't be in core.time.
@safe unittest
{
    assert(std.datetime.Date(2010, 9, 7) + dur!"days"(5) ==
           std.datetime.Date(2010, 9, 12));

    assert(std.datetime.Date(2010, 9, 7) - std.datetime.Date(2010, 10, 3) ==
           dur!"days"(-26));
}

@safe unittest
{
    import std.traits : hasUnsharedAliasing;
    /* Issue 6642 */
    static assert(!hasUnsharedAliasing!Date);
    static assert(!hasUnsharedAliasing!TimeOfDay);
    static assert(!hasUnsharedAliasing!DateTime);
    static assert(!hasUnsharedAliasing!SysTime);
}

// @@@DEPRECATED_2.089@@@
deprecated("To be removed in 2.089. Use std.datetime.stopwatch.AutoStart.") alias AutoStart = Flag!"autoStart";


// @@@DEPRECATED_2.089@@@
deprecated("To be removed in 2.089. Use std.datetime.stopwatch.StopWatch.")
@safe struct StopWatch
{
public:

    this(AutoStart autostart) @nogc
    {
        if (autostart)
            start();
    }

    @nogc @safe unittest
    {
        auto sw = StopWatch(Yes.autoStart);
        sw.stop();
    }


    bool opEquals(const StopWatch rhs) const pure nothrow @nogc
    {
        return opEquals(rhs);
    }

    bool opEquals(const ref StopWatch rhs) const pure nothrow @nogc
    {
        return _timeStart == rhs._timeStart &&
               _timeMeasured == rhs._timeMeasured;
    }


    void reset() @nogc
    {
        if (_flagStarted)
        {
            // Set current system time if StopWatch is measuring.
            _timeStart = TickDuration.currSystemTick;
        }
        else
        {
            // Set zero if StopWatch is not measuring.
            _timeStart.length = 0;
        }

        _timeMeasured.length = 0;
    }

    @nogc @safe unittest
    {
        StopWatch sw;
        sw.start();
        sw.stop();
        sw.reset();
        assert(sw.peek().to!("seconds", real)() == 0);
    }


    void start() @nogc
    {
        assert(!_flagStarted);
        _flagStarted = true;
        _timeStart = TickDuration.currSystemTick;
    }

    @nogc @system unittest
    {
        StopWatch sw;
        sw.start();
        auto t1 = sw.peek();
        bool doublestart = true;
        try
            sw.start();
        catch (AssertError e)
            doublestart = false;
        assert(!doublestart);
        sw.stop();
        assert((t1 - sw.peek()).to!("seconds", real)() <= 0);
    }


    void stop() @nogc
    {
        assert(_flagStarted);
        _flagStarted = false;
        _timeMeasured += TickDuration.currSystemTick - _timeStart;
    }

    @nogc @system unittest
    {
        StopWatch sw;
        sw.start();
        sw.stop();
        auto t1 = sw.peek();
        bool doublestop = true;
        try
            sw.stop();
        catch (AssertError e)
            doublestop = false;
        assert(!doublestop);
        assert((t1 - sw.peek()).to!("seconds", real)() == 0);
    }


    TickDuration peek() const @nogc
    {
        if (_flagStarted)
            return TickDuration.currSystemTick - _timeStart + _timeMeasured;

        return _timeMeasured;
    }

    @nogc @safe unittest
    {
        StopWatch sw;
        sw.start();
        auto t1 = sw.peek();
        sw.stop();
        auto t2 = sw.peek();
        auto t3 = sw.peek();
        assert(t1 <= t2);
        assert(t2 == t3);
    }


    void setMeasured(TickDuration d) @nogc
    {
        reset();
        _timeMeasured = d;
    }

    @nogc @safe unittest
    {
        StopWatch sw;
        TickDuration t0;
        t0.length = 100;
        sw.setMeasured(t0);
        auto t1 = sw.peek();
        assert(t0 == t1);
    }


    bool running() @property const pure nothrow @nogc
    {
        return _flagStarted;
    }

    @nogc @safe unittest
    {
        StopWatch sw1;
        assert(!sw1.running);
        sw1.start();
        assert(sw1.running);
        sw1.stop();
        assert(!sw1.running);
        StopWatch sw2 = Yes.autoStart;
        assert(sw2.running);
        sw2.stop();
        assert(!sw2.running);
        sw2.start();
        assert(sw2.running);
    }




private:

    // true if observing.
    bool _flagStarted = false;

    // TickDuration at the time of StopWatch starting measurement.
    TickDuration _timeStart;

    // Total time that StopWatch ran.
    TickDuration _timeMeasured;
}

deprecated @safe unittest
{
    void writeln(S...)(S args){}
    static void bar() {}

    StopWatch sw;
    enum n = 100;
    TickDuration[n] times;
    TickDuration last = TickDuration.from!"seconds"(0);
    foreach (i; 0 .. n)
    {
       sw.start(); //start/resume mesuring.
       foreach (unused; 0 .. 1_000_000)
           bar();
       sw.stop();  //stop/pause measuring.
       //Return value of peek() after having stopped are the always same.
       writeln((i + 1) * 1_000_000, " times done, lap time: ",
               sw.peek().msecs, "[ms]");
       times[i] = sw.peek() - last;
       last = sw.peek();
    }
    real sum = 0;
    // To get the number of seconds,
    // use properties of TickDuration.
    // (seconds, msecs, usecs, hnsecs)
    foreach (t; times)
       sum += t.hnsecs;
    writeln("Average time: ", sum/n, " hnsecs");
}


// @@@DEPRECATED_2.089@@@
deprecated("To be removed in 2.089. Use std.datetime.stopwatch.benchmark.")
TickDuration[fun.length] benchmark(fun...)(uint n)
{
    TickDuration[fun.length] result;
    StopWatch sw;
    sw.start();

    foreach (i, unused; fun)
    {
        sw.reset();
        foreach (j; 0 .. n)
            fun[i]();
        result[i] = sw.peek();
    }

    return result;
}

deprecated @safe unittest
{
    import std.conv : to;
    int a;
    void f0() {}
    void f1() {auto b = a;}
    void f2() {auto b = to!string(a);}
    auto r = benchmark!(f0, f1, f2)(10_000);
    auto f0Result = to!Duration(r[0]); // time f0 took to run 10,000 times
    auto f1Result = to!Duration(r[1]); // time f1 took to run 10,000 times
    auto f2Result = to!Duration(r[2]); // time f2 took to run 10,000 times
}

deprecated @safe unittest
{
    int a;
    void f0() {}
    //void f1() {auto b = to!(string)(a);}
    void f2() {auto b = (a);}
    auto r = benchmark!(f0, f2)(100);
}


// @@@DEPRECATED_2.089@@@
deprecated("To be removed in 2.089. Use std.datetime.stopwatch.benchmark.") @safe struct ComparingBenchmarkResult
{
    @property real point() const pure nothrow
    {
        return _baseTime.length / cast(const real)_targetTime.length;
    }


    @property public TickDuration baseTime() const pure nothrow
    {
        return _baseTime;
    }


    @property public TickDuration targetTime() const pure nothrow
    {
        return _targetTime;
    }

private:

    this(TickDuration baseTime, TickDuration targetTime) pure nothrow
    {
        _baseTime = baseTime;
        _targetTime = targetTime;
    }

    TickDuration _baseTime;
    TickDuration _targetTime;
}


// @@@DEPRECATED_2.089@@@
deprecated("To be removed in 2.089. Use std.datetime.stopwatch.benchmark.")
ComparingBenchmarkResult comparingBenchmark(alias baseFunc,
                                            alias targetFunc,
                                            int times = 0xfff)()
{
    auto t = benchmark!(baseFunc, targetFunc)(times);
    return ComparingBenchmarkResult(t[0], t[1]);
}

deprecated @safe unittest
{
    void f1x() {}
    void f2x() {}
    @safe void f1o() {}
    @safe void f2o() {}
    auto b1 = comparingBenchmark!(f1o, f2o, 1)(); // OK
    //writeln(b1.point);
}

//Bug# 8450
deprecated @system unittest
{
    @safe    void safeFunc() {}
    @trusted void trustFunc() {}
    @system  void sysFunc() {}
    auto safeResult  = comparingBenchmark!((){safeFunc();}, (){safeFunc();})();
    auto trustResult = comparingBenchmark!((){trustFunc();}, (){trustFunc();})();
    auto sysResult   = comparingBenchmark!((){sysFunc();}, (){sysFunc();})();
    auto mixedResult1  = comparingBenchmark!((){safeFunc();}, (){trustFunc();})();
    auto mixedResult2  = comparingBenchmark!((){trustFunc();}, (){sysFunc();})();
    auto mixedResult3  = comparingBenchmark!((){safeFunc();}, (){sysFunc();})();
}


// @@@DEPRECATED_2.089@@@
deprecated("To be removed in 2.089. Use std.datetime.stopwatch.StopWatch.") @safe auto measureTime(alias func)()
if (isSafe!((){StopWatch sw; unaryFun!func(sw.peek());}))
{
    struct Result
    {
        private StopWatch _sw = void;
        this(AutoStart as)
        {
            _sw = StopWatch(as);
        }
        ~this()
        {
            unaryFun!(func)(_sw.peek());
        }
    }
    return Result(Yes.autoStart);
}

deprecated("Use std.datetime.stopwatch.StopWatch. This will be removed in 2.089.") auto measureTime(alias func)()
if (!isSafe!((){StopWatch sw; unaryFun!func(sw.peek());}))
{
    struct Result
    {
        private StopWatch _sw = void;
        this(AutoStart as)
        {
            _sw = StopWatch(as);
        }
        ~this()
        {
            unaryFun!(func)(_sw.peek());
        }
    }
    return Result(Yes.autoStart);
}

deprecated @safe unittest
{
    {
        auto mt = measureTime!((TickDuration a)
            { /+ do something when the scope is exited +/ });
        // do something that needs to be timed
    }

    // functionally equivalent to the above
    {
        auto sw = StopWatch(Yes.autoStart);
        scope(exit)
        {
            TickDuration a = sw.peek();
            /+ do something when the scope is exited +/
        }
        // do something that needs to be timed
    }
}

deprecated @safe unittest
{
    import std.math : isNaN;

    @safe static void func(TickDuration td)
    {
        assert(!td.to!("seconds", real)().isNaN());
    }

    auto mt = measureTime!(func)();

    /+
    with (measureTime!((a){assert(a.seconds);}))
    {
        // doSomething();
        // @@@BUG@@@ doesn't work yet.
    }
    +/
}

deprecated @safe unittest
{
    import std.math : isNaN;

    static void func(TickDuration td)
    {
        assert(!td.to!("seconds", real)().isNaN());
    }

    auto mt = measureTime!(func)();

    /+
    with (measureTime!((a){assert(a.seconds);}))
    {
        // doSomething();
        // @@@BUG@@@ doesn't work yet.
    }
    +/
}

//Bug# 8450
deprecated @system unittest
{
    @safe    void safeFunc() {}
    @trusted void trustFunc() {}
    @system  void sysFunc() {}
    auto safeResult  = measureTime!((a){safeFunc();})();
    auto trustResult = measureTime!((a){trustFunc();})();
    auto sysResult   = measureTime!((a){sysFunc();})();
}
