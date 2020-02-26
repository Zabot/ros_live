build=build

all: ros_live.iso

clean:
	rm -rf image
	rm -f bootx64.efi
	rm -f efiboot.img
	rm -f core.img
	rm -f bios.img
	rm -f ros_live.iso
	rm -f persistence.img

chroot:
	debootstrap \
		--arch=amd64 \
		--variant=minbase \
		stretch \
		chroot \
		http://ftp.us.debian.org/debian/
	./prepare_chroot.sh

image/live/filesystem.squashfs: chroot
	mkdir -p image/live/
	mksquashfs chroot image/live/filesystem.squashfs -e boot -noappend

image/vmlinuz: chroot
	mkdir -p image/
	cp chroot/boot/vmlinuz-* image/vmlinuz

image/initrd: chroot
	mkdir -p image/
	cp chroot/boot/initrd.img-* image/initrd

image/ROS_LIVE:
	mkdir -p image/
	touch image/ROS_LIVE

bootx64.efi: grub.cfg
	grub-mkstandalone \
			--format=x86_64-efi \
			--output=bootx64.efi \
			--locales="" \
			--fonts="" \
			--themes="" \
			"boot/grub/grub.cfg=grub.cfg"

efiboot.img: bootx64.efi
	dd if=/dev/zero of=efiboot.img bs=1M count=10
	mkfs.vfat efiboot.img
	mmd -i efiboot.img efi efi/boot
	mcopy -i efiboot.img ./bootx64.efi ::efi/boot/
	mkdir boot
	mount -o loop efiboot.img boot
	mkdir -p boot/efi/boot
	cp bootx64.efi boot/efi/boot/
	umount -l boot
	rmdir boot

core.img: grub.cfg
	grub-mkstandalone \
			--format=i386-pc \
			--output=core.img \
			--install-modules="linux normal iso9660 biosdisk memdisk search tar ls" \
			--modules="linux normal iso9660 biosdisk search" \
			--locales="" \
			--fonts="" \
			--themes="" \
			"boot/grub/grub.cfg=grub.cfg"

bios.img: core.img
	cat /usr/lib/grub/i386-pc/cdboot.img core.img > bios.img

persistence.img: persistence.conf
	dd if=/dev/zero of=persistence.img bs=1M count=1028
	mkfs.ext4 persistence.img -L persistence
	mkdir -p p
	mount -o loop persistence.img p
	cp persistence.conf p/
	umount -l p
	rmdir p

ros_live.iso: efiboot.img bios.img image/live/filesystem.squashfs image/vmlinuz image/initrd image/ROS_LIVE persistence.img
	xorriso \
			-as mkisofs \
			-iso-level 3 \
			-full-iso9660-filenames \
			-volid "ROS_LIVE" \
			-output "ros_live.iso" \
			-eltorito-boot \
					boot/grub/bios.img \
					-no-emul-boot \
					-boot-load-size 4 \
					-boot-info-table \
					--eltorito-catalog boot/grub/boot.cat \
			--grub2-boot-info \
			--grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
			-eltorito-alt-boot \
					-e EFI/efiboot.img \
					-no-emul-boot \
			-append_partition 2 0xef efiboot.img \
			-graft-points \
					"image" \
					/boot/grub/bios.img=bios.img \
					/EFI/efiboot.img=efiboot.img \
			-append_partition 3 0x0c persistence.img

