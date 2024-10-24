import os
import sys
import subprocess
import openai  # For OpenAI API
# import anthropic  # For Anthropic's Claude API (uncomment if using)

# Configuration
API_SERVICE = 'openai'  # or 'anthropic'
PROMPT_TEMPLATE_FILE = 'prompt.txt'
MAX_TOKENS = 2048  # Adjust based on the model's limits

def get_modified_files():
    result = subprocess.run(['git', 'diff', '--cached', '--name-only'], capture_output=True, text=True)
    files = result.stdout.strip().split('\n')
    return [f for f in files if f and os.path.isfile(f)]

def read_file_contents(file_list):
    file_contents = {}
    for file_path in file_list:
        with open(file_path, 'r') as f:
            file_contents[file_path] = f.read()
    return file_contents

def get_diff():
    result = subprocess.run(['git', 'diff', '--cached'], capture_output=True, text=True)
    return result.stdout.strip()

def load_prompt_template():
    with open(PROMPT_TEMPLATE_FILE, 'r') as f:
        return f.read()

def create_prompt(file_contents, diff):
    prompt_template = load_prompt_template()
    prompt = prompt_template.format(file_contents=file_contents, diff=diff)
    return prompt

def send_to_openai(prompt):
    openai.api_key = os.getenv('OPENAI_API_KEY')
    response = openai.ChatCompletion.create(
        model='gpt-3.5-turbo',  # or 'gpt-4' if available
        messages=[
            {"role": "system", "content": "You are a senior code reviewer specializing in mobile development."},
            {"role": "user", "content": prompt}
        ],
        max_tokens=MAX_TOKENS,
        n=1,
        stop=None,
        temperature=0.5,
    )
    return response['choices'][0]['message']['content']

def main():
    modified_files = get_modified_files()
    if not modified_files:
        print("No modified files to review.")
        sys.exit(0)

    file_contents = read_file_contents(modified_files)
    diff = get_diff()

    # Prepare data for the prompt
    files_str = ""
    for path, content in file_contents.items():
        files_str += f"File: {path}\nContent:\n```\n{content}\n```\n\n"

    prompt = create_prompt(files_str, diff)

    print("Sending code to AI agent for review...\n")

    if API_SERVICE == 'openai':
        feedback = send_to_openai(prompt)
    else:
        # Implement Claude API call here
        pass

    print("=== AI Code Review Feedback ===\n")
    print(feedback)

    # Optionally, decide whether to block the push based on the feedback
    # For now, we'll allow the push to proceed
    sys.exit(0)

if __name__ == '__main__':
    main()
