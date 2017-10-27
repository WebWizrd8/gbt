package ttime

import (
    "time"

    "github.com/jtyr/gbt/gbt/core/car"
    "github.com/jtyr/gbt/gbt/core/utils"
)

// Car inherits the core.Car.
type Car struct {
    car.Car
}

// Init initializes the car.
func (c *Car) Init() {
    defaultRootBg := utils.GetEnv("GBT_CAR_BG", "light_blue")
    defaultRootFg := utils.GetEnv("GBT_CAR_FG", "light_gray")
    defaultRootFm := utils.GetEnv("GBT_CAR_FM", "none")
    defaultDatetimeBg := defaultRootBg
    defaultDatetimeFg := defaultRootFg
    defaultDatetimeFm := defaultRootFm
    defaultDateBg := defaultRootBg
    defaultDateFg := defaultRootFg
    defaultDateFm := defaultRootFm
    defaultTimeBg := defaultRootBg
    defaultTimeFg := "light_yellow"
    defaultTimeFm := defaultRootFm

    c.Model = map[string]car.ModelElement {
        "root": {
            Bg: utils.GetEnv("GBT_CAR_TIME_BG", defaultRootBg),
            Fg: utils.GetEnv("GBT_CAR_TIME_FG", defaultRootFg),
            Fm: utils.GetEnv("GBT_CAR_TIME_FM", defaultRootFm),
            Text: utils.GetEnv("GBT_CAR_TIME_FORMAT", " {{ DateTime }} "),
        },
        "DateTime": {
            Bg: utils.GetEnv(
                "GBT_CAR_TIME_USERHOST_BG", utils.GetEnv(
                    "GBT_CAR_TIME_BG", defaultDatetimeBg)),
            Fg: utils.GetEnv(
                "GBT_CAR_TIME_USERHOST_FG", utils.GetEnv(
                    "GBT_CAR_TIME_FG", defaultDatetimeFg)),
            Fm: utils.GetEnv(
                "GBT_CAR_TIME_USERHOST_FM", utils.GetEnv(
                    "GBT_CAR_TIME_FM", defaultDatetimeFm)),
            Text: utils.GetEnv(
                "GBT_CAR_TIME_USERHOST_FORMAT", "{{ Date }} {{ Time }}"),
        },
        "Date": {
            Bg: utils.GetEnv(
                "GBT_CAR_TIME_DATE_BG", utils.GetEnv(
                    "GBT_CAR_TIME_BG", defaultDateBg)),
            Fg: utils.GetEnv(
                "GBT_CAR_TIME_DATE_FG", utils.GetEnv(
                    "GBT_CAR_TIME_FG", defaultDateFg)),
            Fm: utils.GetEnv(
                "GBT_CAR_TIME_DATE_FM", utils.GetEnv(
                    "GBT_CAR_TIME_FM", defaultDateFm)),
            Text: time.Now().Format(
                utils.GetEnv("GBT_CAR_TIME_DATE_FORMAT", "Mon 02 Jan")),
        },
        "Time": {
            Bg: utils.GetEnv(
                "GBT_CAR_TIME_TIME_BG", utils.GetEnv(
                    "GBT_CAR_TIME_BG", defaultTimeBg)),
            Fg: utils.GetEnv(
                "GBT_CAR_TIME_TIME_FG", utils.GetEnv(
                    "GBT_CAR_TIME_FG", defaultTimeFg)),
            Fm: utils.GetEnv(
                "GBT_CAR_TIME_TIME_FM", utils.GetEnv(
                    "GBT_CAR_TIME_FM", defaultTimeFm)),
            Text: time.Now().Format(
                utils.GetEnv("GBT_CAR_TIME_TIME_FORMAT", "15:04:05")),
        },
    }

    c.Display = utils.GetEnvBool("GBT_CAR_TIME_DISPLAY", true)
    c.Wrap = utils.GetEnvBool("GBT_CAR_TIME_WRAP", false)
    c.Sep = utils.GetEnv("GBT_CAR_TIME_SEP", "\000")
}
