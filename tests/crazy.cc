#include<iostream>
#include<cstring>
struct a { unsigned lang;};
struct b {
	void operator++(int) { 
		decltype(this) n = new struct b;
		memcpy(this,n,sizeof(n));
		((struct a*)this) -> lang = (unsigned)((unsigned)-1 + 1);
	}
};
int main() {
	struct b B;
	B++;
	std::cout << ((struct a*)&B)->lang << "\n";
}
