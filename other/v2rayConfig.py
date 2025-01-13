# 生成配置 v2ray 所需的随机值

import random
import uuid
import string

def generate_port():
    # 指定随机数范围在 1024 到 65535 之间
    return random.randint(1024, 65535)

def generate_two_ports():
    # 生成两个随机端口
    port1 = generate_port()
    port2 = generate_port()
    return port1, port2

def generate_user_id():
    # 生成随机用户ID（UUID）
    return str(uuid.uuid4())

def generate_random_string():
    # 生成包含大写字母、小写字母和数字的 8 位随机路径
    upper_case_letters = string.ascii_uppercase
    lower_case_letters = string.ascii_lowercase
    digits = string.digits

    random_upper = random.choice(upper_case_letters)
    random_lower = random.choice(lower_case_letters)
    random_digit = random.choice(digits)

    remaining_length = 5
    random_chars = ''.join(
        random.choice(upper_case_letters + lower_case_letters + digits) for _ in range(remaining_length))

    # 重置所有字符，确保随机性
    random_characters = list(random_chars)
    random.shuffle(random_characters)

    # 在随机位置添加所需的三个字符
    random_characters.insert(random.randint(0, remaining_length), random_upper)
    random_characters.insert(random.randint(0, remaining_length + 1), random_lower)
    random_characters.insert(random.randint(0, remaining_length + 2), random_digit)

    return ''.join(random_characters)

# 生成端口、用户ID和路径
port1, port2 = generate_two_ports()
user_id = generate_user_id()
random_string = generate_random_string()

print("网站端口:", port1)
print("代理端口:", port2)
print("用户ID:", user_id)
print("路径:", random_string)
