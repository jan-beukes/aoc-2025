function invalid_part_one(s)
    local half_len = math.floor(#s/2)
    return #s % 2 == 0 and s:sub(1, half_len) == s:sub(-half_len)
end

function invalid_part_two(s)
    d = s .. s
    return d:find(s, 2) ~= #s + 1
end

content = io.open("input.txt"):read()
total_p1 = 0
total_p2 = 0
for from, to in content:gmatch("(%d+)%-(%d+)") do
    for i = tonumber(from), tonumber(to) do
        s = tostring(i)
        if invalid_part_one(s) then
            total_p1 = total_p1 + i
            total_p2 = total_p2 + i
        elseif invalid_part_two(s) then
            total_p2 = total_p2 + i
        end
    end
end

print("Part one:", total_p1)
print("Part two:", total_p2)
