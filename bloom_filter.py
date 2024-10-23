class BloomFilter:
    def __init__(self, size, hash_functions):
        self.size = size
        self.hash_functions = hash_functions
        self.bit_array = [0] * size
    
    def add(self, element):
        print(f"Adding element '{element}' to the Bloom Filter.")
        for seed in range(self.hash_functions):
            result = hash(str(seed) + str(element)) % self.size
            print(f"Hash function {seed + 1} result: {result}")
            self.bit_array[result] = 1
        print(f"Bit array after adding '{element}': {self.bit_array}\n")
    
    def contains(self, element):
        print(f"Checking if element '{element}' is in the Bloom Filter.")
        for seed in range(self.hash_functions):
            result = hash(str(seed) + str(element)) % self.size
            print(f"Hash function {seed + 1} result: {result}")
            if self.bit_array[result] == 0:
                print(f"Element '{element}' is definitely NOT in the Bloom Filter.\n")
                return False
        print(f"Element '{element}' MIGHT be in the Bloom Filter.\n")
        return True

# Test the implementation
bf = BloomFilter(20, 3)
bf.add("4")
print("Contains 'test':", bf.contains("test"))
print("Contains 'test2':", bf.contains("test2"))
