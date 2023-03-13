using HDF5

time = collect(range(0, 100))

voltage_1 = sin.(time)
voltage_2 = voltage_1 .+ 10

f = h5open("experiments.h5", "w")
attributes(f)["description"] = "This is a mock experiment with voltage values over time"

# Creating group and datasets for experiment 1
grp_1 = create_group(f, "experiment_1")

dset_time_1, _ = create_dataset(grp_1, "time", time)
write(dset_time_1, time)
attributes(dset_time_1)["unit"] = "ms"

dset_voltage_1, _ = create_dataset(grp_1, "voltage", voltage_1)
write(dset_voltage_1, voltage_1)
attributes(dset_voltage_1)["unit"] = "mV"

# Creating group and datasets for experiment 2
grp_2 = create_group(f, "experiment_2")

dset_time_2, _ = create_dataset(grp_2, "time", time)
write(dset_time_2, time)
attributes(dset_time_2)["unit"] = "ms"

dset_voltage_2, _ = create_dataset(grp_2, "voltage", voltage_2)
write(dset_voltage_2, voltage_2)
attributes(dset_voltage_2)["unit"] = "mV"

# Creating group and subgroup for experiment 3
grp_3 = create_group(f, "experiment_invalid")

# Looping through and accessing
println("Experiments: $(keys(f))")
for experiment in keys(f)
    if haskey(f[experiment], "voltage")
        println(experiment)
        voltage = f[experiment]["voltage"]
        println(voltage)
        println(collect(voltage))
        println("First voltage: $(voltage[1])")
    else
        println("No voltage values for: $experiment")
    end
end

# Creating and accessing a subgroup
grp_4 = create_group(grp_3, "subgroup")
dset_time_4, _ = create_dataset(grp_4, "time", time)
write(dset_time_4, time)

println(f["experiment_invalid"]["subgroup"]["time"])
println(collect(dset_time_4))

close(f)
